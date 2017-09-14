module MongoDB
  def self.mmapv1?
    if Mongoid.respond_to?(:default_session)
      Mongoid.default_session.command(serverStatus: 1)['storageEngine']['name'] == 'mmapv1'
    else
      Mongoid.default_client.command(serverStatus: 1).first['storageEngine']['name'] == 'mmapv1'
    end
  end
end
