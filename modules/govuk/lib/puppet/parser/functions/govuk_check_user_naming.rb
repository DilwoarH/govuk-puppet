module Puppet::Parser::Functions
  newfunction(:govuk_check_user_naming, :doc => <<EOS
Verify that a govuk::user resource conforms to naming policy.
EOS
  ) do |args|
    unless args.size == 3
      raise(ArgumentError, "govuk_check_user_naming: wrong number of arguments given #{args.size} for 3")
    end

    uname, fname, email = args
    return if user_in_whitelist?(uname)

    uname_from_full = fname.downcase.split(' ').join.gsub(/[^a-z]/i, '')
    uname_from_email = email.split('@').first.split('.').join.gsub(/[^a-z]/i, '')

    unless uname_from_full == uname_from_email
      raise(Puppet::Error, "govuk_check_user_naming: name in fullname must match name in email")
    end

    unless uname == uname_from_full && uname == uname_from_email
      raise(Puppet::Error, "govuk_check_user_naming: expected username '#{uname}' to be '#{uname_from_full}' based on fullname and email")
    end
  end
end

def user_in_whitelist?(username)
  # Non-human system accounts.
  return true if %w{
    govuk-crawler
    govuk-backup
    govuk-netstorage
  }.include?(username)

  # Existing humans. Do NOT add to this list.
  return true if %w{
    ajlanghorn
    alex_tea
    alext
    benilovj
    benp
    bob
    bradleyw
    dai
    davidt
    dcarley
    elliot
    futurefabric
    garethr
    heathd
    jabley
    jackscotti
    james
    jamiec
    jordan
    kushalp
    minglis
    mwall
    niallm
    ollyl
    ppotter
    psd
    rthorn
    ssharpe
    tekin
    vinayvinay
  }.include?(username)

  return false
end
