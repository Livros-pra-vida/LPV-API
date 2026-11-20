ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

# Bootsnap só acelera a inicialização. No Windows ele fica desligado: o "Controle de Aplicativo"
# (Smart App Control) bloqueia o arquivo bootsnap.so compilado na instalação.
require "bootsnap/setup" unless Gem.win_platform? || ENV["DISABLE_BOOTSNAP"]
