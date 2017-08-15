require 'rest-client'
require 'base64'
require 'json'

class SafeTRest

  def initialize(config_hash={})
    @extension_id = config_hash[:extension_id]
    @user_name    = Base64.strict_encode64(config_hash[:user_name]) if config_hash[:user_name]
    @password     = Base64.strict_encode64(config_hash[:password]) if config_hash[:password]
    @url          = config_hash[:rest_url]
    @role_id      = config_hash[:role_id]
  end

  def get_apps_process_state(guid)
    send_request("GetAppsProcessState", [guid, false])
  end

  def get_package_file_list(guid)
    send_request("GetPackageFileList",[guid])
  end

  def verify_user_account
    response = send_request("iVerifyUserAccount",[@user_name, @password, true])
    status, message = response.split(':')
    raise SafeTError.new("Got empty response from server: #{message}, status: #{status}") if message.to_s.empty?
    case status.downcase
    when 'ok'
      return JSON.parse(Base64.decode64(message), symbolize_names: true)
    when 'error'
      raise SafeTError.new(Base64.decode64(message))
    else
      raise SafeTError.new("Non-Standard status #{status}:#{Base64.decode64(message)}")
    end
  end

  def get_user_history(days)
    send_request("iGetHistory", [@user_name, @password, days])
  end

  def user_account_address_list
    send_request("iUserAccountAddressList",[@user_name, @password])
  end

  def get_folder_list(path)
    send_request("iGetFolderList",[@user_name, @password, false, true, path, 417])
  end

  def safe_share_file(args)
    send_request("iSafeShareFile:",[
        @user_name,
        @password,
        args[:files],
        args[:recipients],
        args[:sender_name],
        args[:sender_address],
        args[:subject],
        args[:message],
        args[:message_encryption_level],
        args[:delivery_method],
        args[:mobile_recipient],
        args[:return_receipt],
        args[:safe_reply],
        args[:max_downloads],
        args[:package_expiry],
        args[:folder_path],
        args[:root_folder_id]
    ])
  end

  def file_upload(args)
    send_request("iFileUpload",[
        @user_name,
        @password,
        args[:file_base64],
        args[:file_name],
        args[:folder_path],
        args[:root_folder_id]
    ])
  end

  def file_download(args)
    send_request("iFileDownload",[
        @user_name,
        @password,
        args[:file_name],
        args[:folder_path],
        args[:root_folder_id]
    ])
  end

  def register_session(url_string)
    response = send_request("RegisterSession",[url_string])
    status, message = response.split(':')
    raise SafeTError.new("Got empty response from server: #{message}, status: #{status}") if message.to_s.empty?
    case status.downcase
      when 'ok'
        return JSON.parse(Base64.decode64(message), symbolize_names: true)
      when 'error'
        raise SafeTError.new(Base64.decode64(message))
      else
        raise SafeTError.new("Non-Standard status #{status}:#{Base64.decode64(message)}")
    end
  end

  private

  def send_request(method, parameters)
    RestClient::Request.execute(
      :verify_ssl => false,
      method: :post,
      url: @url,
      headers: {
        servletRequestID: 'MethodRequest',
      },
      payload: {
          "Username": "",
          "Password": "",
          "RoleID": "#{@role_id}",
          "ExtensionID": "#{@extension_id}",
          "Method": "#{method}",
          "Arguments": parameters
        }.to_json
    )
  end
end

class SafeTError < Exception; end

