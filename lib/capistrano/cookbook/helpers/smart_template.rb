require 'securerandom'
require 'stringio'

# will first try and copy the file:
# config/deploy/#{full_app_name}/#{from}.erb
# to:
# shared/config/to
# if the original source path doesn exist then it will
# search in:
# config/deploy/shared/#{from}.erb
# otherwise it will search in the gems template directory
# this allows files which are common to all enviros to
# come from a single source while allowing specific
# ones to be over-ridden
# if the target file name is the same as the source then
# the second parameter can be left out
def smart_template(from, to, as_root=false)
  if from_erb_path = template_file(from)
    from_erb = StringIO.new(ERB.new(File.read(from_erb_path)).result(binding))
    upload!(from_erb, to) unless as_root
    sudo_upload!(from_erb, to) if as_root
    info "copying: #{from} to: #{to}"
  else
    error "error #{from} not found"
  end
end

def template_file(name)
  if File.exist?((file = "config/deploy/#{fetch(:stage)}/#{name}.erb"))
    return file
  elsif File.exist?((file = "config/deploy/shared/#{name}.erb"))
    return file
  elsif File.exist?((file = "config/deploy/templates/#{name}.erb"))
    return file
  elsif File.exist?(file = File.expand_path("../templates/#{name}.erb",File.dirname(__FILE__)))
    return file    
  end
  return nil
end

def sudo_upload!(file_path, remote_path, mode: '644', owner: 'root:root')
  tmp_path = "/tmp/#{SecureRandom.uuid}"

  upload!(file_path, tmp_path)

  execute(:sudo, :mkdir, '-p', File.dirname(remote_path))
  execute(:sudo, :mv, '-f', tmp_path, remote_path)
  execute(:sudo, :chmod, mode, remote_path)
  execute(:sudo, :chown, owner, remote_path)
end