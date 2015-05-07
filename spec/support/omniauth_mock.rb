
class OmniauthMock

  def self.setup_login
    prepare_test
    self.valid_credentials
  end

  def self.setup_invalid_login
    prepare_test
    self.invalid_credentials
  end

  def self.setup_no_uid_invalid_login
    prepare_test
    self.no_uid_invalid_credentials
  end


  def self.prepare_test
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:spotify] = nil
  end

  def self.invalid_credentials
    OmniAuth.config.mock_auth[:spotify] = :invalid_credentials
  end

  def self.valid_credentials
    OmniAuth.config.mock_auth[:spotify] = OmniAuth::AuthHash.new({
              provider: 'spotify',
              uid: '1234567',
              info: {
                name: "1337_haxor",
                image: "www.myface.com/123.png",
                email: "myface@hullo.com"
              },
              credentials: {
                token: "token",
                refresh_token: "refresh_token"
              },
              extra: {
                raw_info: {
                  href: "my_spotify_link.com"
                }
              }
            })
  end

  def self.no_uid_invalid_credentials
    OmniAuth.config.mock_auth[:spotify] = OmniAuth::AuthHash.new({
              provider: 'spotify',
              info: {
                name: "1337_haxor",
                image: "www.myface.com/123.png",
                email: "myface@hullo.com"
              },
              credentials: {
                token: "token",
                refresh_token: "refresh_token"
              },
              extra: {
                raw_info: {
                  href: "my_spotify_link.com"
                }
              }
            })
  end


end
