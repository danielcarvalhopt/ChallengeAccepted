# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

State.create(
    [
    		{ description: "Unconfirmed"},	# ainda não foi pago pelo proponente
    		{ description: "Cancelled"},		# pagamento pelo proponente falhou
        { description: 'Proposed'},			# pago e proposto
        { description: 'In Progress'},	# aceite pelo desafiado
        { description: 'Failed'},				# o desafiado não cumpriu o desafio
        { description: 'Completed'}			# o desafiado cumpriu o desafio
    ]
)

User.create name:"beatgodes", email: "cristiano.sousa126@gmail.com", password: "12345678"
User.create name:"insatisfeito", email: "dapcarvalho@gmail.com", password: "12345678"
