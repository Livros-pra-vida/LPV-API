namespace :lpv do
  desc "Criptografa os dados que foram salvos antes da criptografia (chat global, CPF, telefone)"
  task criptografar: :environment do
    { Message => "mensagens do chat", User => "usuários" }.each do |modelo, nome|
      total = 0
      modelo.find_each do |registro|
        registro.encrypt
        total += 1
      end
      puts "#{nome}: #{total} registro(s) criptografado(s)"
    end
  end
end
