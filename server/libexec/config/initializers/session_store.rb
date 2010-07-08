# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_deltacloud-framework_session',
  :secret      => '2f8c7e1de10186f37efa57c9dd816eb2abb7f780fba8844ef73b3e6745101da849e30e54dcf6e4078fc43fce76ead4d7e0d1d06d40646d876f338186810cae18'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
