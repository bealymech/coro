using JuMP
# using CPLEX
using Cbc
#  cd("C:\\Users\\Eric Soutil\\Desktop\\Exo4") 

function lireUneSeuleDonnee(data::Array{String,1}, cpt::Int64)
	line = data[cpt]
	cpt = cpt + 1
	dl = split(line, " ")
	donneeLue = parse(Int64, dl[1])
	return donneeLue, cpt
end

function lireUnVecteurInt(data::Array{String,1}, cpt::Int64, dim::Int64)
	vecteurLu = ones(Int64, dim)
	line = data[cpt]
	cpt = cpt + 1
	dl = split(line, " ")
	for j in 1:dim
		vecteurLu[j] = parse(Int64, dl[j])
	end
	return vecteurLu, cpt
end

function lireUnVecteurFloat(data::Array{String,1}, cpt::Int64, dim::Int64)
	vecteurLu = ones(Float64, dim)
	line = data[cpt]
	cpt = cpt + 1
	dl = split(line, " ")
	for j in 1:dim
		vecteurLu[j] = parse(Float64, dl[j])
	end
	return vecteurLu, cpt
end

function lireDonnees(fichier::String) 
	#A = Array{Int64}(undef, 4, 4, 4)
	#pr = ones(Int64,4,4,4)
	# Si le fichier "./data/test.txt" existe
	if isfile("./data/"*fichier)
		# L’ouvrir
		myFile = open("./data/"*fichier)
		# Lire toutes les lignes d’un fichier
		data = readlines(myFile) #Retourne un tableau de String
		# On retire les lignes vides et les commentaires :
		data = filter(line->length(line) > 0 && line[1] != '#', data)
		
		cpt = 1
		
		nc,   cpt = lireUneSeuleDonnee(data, cpt)
		ns,   cpt = lireUneSeuleDonnee(data, cpt)		
		maxp, cpt = lireUnVecteurInt(data, cpt, ns)
		maxv, cpt = lireUnVecteurInt(data, cpt, ns)
		pc,   cpt = lireUnVecteurInt(data, cpt, nc)
		vu,   cpt = lireUnVecteurInt(data, cpt, nc)
		pr,   cpt = lireUnVecteurInt(data, cpt, nc)
		r,    cpt = lireUnVecteurFloat(data, cpt, ns)

		# Fermer le fichier
		close(myFile)
	end
	return nc, ns, maxp, maxv, pc, vu, pr, r
end

function val(i::Int64) 
	if i == 1 return "Avant" end
	if i == 2 return "Milieu" end
	if i == 3 return "Arriere" end
	return "X"
end

function dual()

	m = Model(Cbc.Optimizer)
	#m = Model(CPLEX.Optimizer)

	@variable(m, y[i in 1:2] >= 0)
	@objective(m, Max, 5*y[1]+7*y[2])
	@constraint(m, c1, y[1] + 2*y[2] <= 4)
	@constraint(m, c2, 3*y[1] + y[2] <= 5)
	@constraint(m, c3, 2*y[1] - 3*y[2] <= 2)
	@constraint(m, c4, 6*y[1] + 5*y[2] <= 6)

	print(m)
	optimize!(m)
	println("\n max(D) = w* = ", JuMP.objective_value(m))
	for i in 1:2
		println("y[", i, "] = ", string(JuMP.value(y[i])))
	end
	
	
end

function primal()

	m = Model(Cbc.Optimizer)
	#m = Model(CPLEX.Optimizer)
	c = [ 4, 5, 2, 6]
	l1 = [1, 3, 2, 6]
	l2 = [2, 1, -3, 5]

	@variable(m, x[i in 1:4] >= 0)
	@objective(m, Min, sum(c[i]*x[i] for i in 1:4))
	@constraint(m, c1, sum(l1[i]*x[i] for i in 1:4) >= 5)
	@constraint(m, c2, sum(l2[i]*x[i] for i in 1:4) >= 7)
	
	print(m)
	optimize!(m)
	println("\n min(P) = z* = ", JuMP.objective_value(m))
	for i in 1:4
		println("x[", i, "] = ", string(JuMP.value(x[i])))
	end
	
	
end

primal()
dual()