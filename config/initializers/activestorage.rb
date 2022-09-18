Rails.application.config.after_initialize do
  ActiveStorage::Blob.class_eval do
    alias_method :upload_without_unfurling_original, :upload_without_unfurling

    def upload_without_unfurling(io)
      begin
        extname = filename.extension_with_delimiter
        if extname == ".png" || extname == ".jpg" || extname == ".jpeg"
          ActiveStorage::Variation
            .wrap({ convert: "webp", quality: 80 })
            .transform(io) do |output|
              unfurl output, identify: identify
              upload_without_unfurling_original(output)
              update_column(:content_type, "image/webp")
              update_column(:checksum, Digest::MD5.file(output).base64digest)
              update_column(:byte_size, File.size(output))
              update_column(:filename, filename.base + ".webp")
            end
        else
          upload_without_unfurling_original(io)
        end
      rescue StandardError
        upload_without_unfurling_original(io)
      end
    end
  end
end
