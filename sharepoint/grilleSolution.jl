using JuMP
using Cbc

function lireGrille(fichier::String)
	grille = fill(0, (9, 9))
	# Le fichier est supposé se trouver dans le répertoire data
	# Si le fichier "./data/test.txt" existe
	if isfile("./data/"*fichier)
		# L’ouvrir
		myFile = open("./data/"*fichier)
		# Lire toutes les lignes d’un fichier
		data = readlines(myFile) #Retourne un tableau de String
		# On retire les lignes vides et les commentaires :
		data = filter(line->length(line) > 0 && line[1] != '#', data)
			
		for i in 1:9
			line = data[i]
			dl = split(line, " ")
			for j in 1:9
				grille[i,j] = parse(Int64, dl[j])
			end
		end
		
		# Fermer le fichier
		close(myFile)
	end
	return grille
end

function tracerLigne() 
	print(" ")
	for i in 1:23 print("-") end
	println()
end


function grille()

    l = [5,3,3,5,2]
	c = [5,5,2,2,4] 
	I = 5
	J = 5


    # Créer le modèle
    m = Model(Cbc.Optimizer)

    ### Fonction objectif
    @objective(m, Max, 1)
    
    ### Variables
    # x[i, j, k] = 1 if cell (i, j) has value k
    @variable(m, x[i in 1:I, j in 1:J], Bin)
    @variable(m, y[i in 1:I, j in 1:J, k in 1:4], Bin)

    ### Contraintes
	# A compléter
	@constraint(m, ligne[i in 1:I], sum(x[i,j] for j in 1:J)==l[i])
	@constraint(m, col[j in 1:J], sum(x[i,j] for i in 1:I)==c[j])
	@constraint(m, deuxPortes[i in 1:I, j in 1:J],
	      2*x[i,j]== sum(y[i,j,k] for k in 1:4))
	@constraint(m, continuite13[i in 2:I, j in 1:J], 
	              y[i,j,1]==y[i-1,j,3])
	@constraint(m, continuite24[i in 1:I, j in 1:(J-1)], 
	              y[i,j,2]==y[i,j+1,4])			  
	#println(m)
	
    ### Résoudre le problème
    optimize!(m)

	

    ### Afficher la solution
	# Pour récupérer la valeur d'une variable : JuMP.value(x[i,j,k])
	for i in 1:I
		for j in 1:J
	#		for k in 1:n
				if (JuMP.value(x[i,j])==1)
					print("┐")
				end
	#		end
	#		print("|")
		end
		println()
	end
		

end


grille()

