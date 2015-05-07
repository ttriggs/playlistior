
class OmniauthMock

  def self.setup_login
    prepare_test
    OmniauthMock.valid_credentials
  end

  def self.setup_invalid_login
    prepare_test
    OmniauthMock.invalid_credentials
  end

  def self.prepare_test
    OmniAuth.config.test_mode = true
    OmniauthMock.clean!
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

  def self.invalid_credentials
    OmniAuth.config.mock_auth[:spotify] = :invalid_credentials
  end

  def self.clean!
    OmniAuth.config.mock_auth[:spotify] = nil
  end
end
