# typed: strict
# frozen_string_literal: true

require "download_strategy"
require_relative "qq_download"

class QQDownloadStrategy < CurlDownloadStrategy
  private

  # Unsigned QQ URLs reject HEAD requests; keep cache names independent of expiring signatures.
  sig { override.params(url: String, timeout: T.nilable(T.any(Float, Integer))).returns(URLMetadata) }
  def resolve_url_basename_time_file_size(url, timeout: nil)
    [url, File.basename(URI(url).path.to_s), nil, nil, nil, false]
  end

  sig {
    override.params(resolved_url: String, to: T.any(Pathname, String), timeout: T.nilable(T.any(Float, Integer)))
            .returns(T.nilable(SystemCommand::Result))
  }
  def _curl_download(resolved_url, to, timeout)
    super(QQDownload.signed_url(resolved_url), to, timeout)
  end
end
