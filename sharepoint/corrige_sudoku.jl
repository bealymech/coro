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


function sudoku(t::Array{Int, 2})

    # Taille de la grille
    n = size(t, 1)


	SetDeb = [1, 4, 7]
	SetDebutBloc = [(i,j) for i in SetDeb, j in SetDeb]
	PreRemplies = [(i,j,k) for i in 1:n, j in 1:n, k in 1:n 
	                                            if t[i,j] == k]


    # Créer le modèle
    m = Model(Cbc.Optimizer)

    ### Fonction objectif
    @objective(m, Max, 1)
    
    ### Variables
    # x[i, j, k] = 1 if cell (i, j) has value k
    @variable(m, x[i in 1:n, j in 1:n, k in 1:n], Bin)

    ### Constraintes
	# A compléter
	@constraint(m, ligne[i in 1:n, k in 1:n], 
	       sum(x[i,j,k] for j in 1:n) == 1)
	@constraint(m, colonne[j in 1:n, k in 1:n], 
	       sum(x[i,j,k] for i in 1:n) == 1)
	@constraint(m, unicite[i in 1:n, j in 1:n], 
	       sum(x[i,j,k] for k in 1:n) == 1)
	@constraint(m, bloc[di in SetDeb, dj in SetDeb, k in 1:n],
            sum(x[i,j,k] for i in di:(di+2), j in dj:(dj+2))==1) 	
    #@constraint(m, bloc[(di,dj) in SetDebutBloc, k in 1:n],
    #       sum(x[i,j,k] for i in di:(di+2), j in dj:(dj+2))==1)	
	@constraint(m, preRemplissage[(i,j,k) in PreRemplies],
	                x[i,j,k] == 1)
	
	
	#print(m)
	
    ### Résoudre le problème
    optimize!(m)

    ### Afficher la solution
	# Pour récupérer la valeur d'une variable : 
	# JuMP.value(x[i,j,k])
	print("objectif = ", JuMP.objective_value(m))
	println()
	for i in 1:n
		for j in 1:n
			for k in 1:n
				if JuMP.value(x[i,j,k])==1 
					print(k, " ")
				end
			end
			print("|")
		end
		println()
	end
	

end

t = lireGrille("grille.txt")

"""
Autres initialisations possible :

t = [
5 0 0 0 6 0 9 0 0;
0 0 3 0 0 0 0 7 0;
0 0 0 0 0 0 0 0 0;
0 7 0 0 0 0 0 1 4;
0 0 8 0 5 0 0 0 0;
0 0 0 2 0 0 0 0 0;
2 0 0 0 0 0 6 0 0;
0 0 0 3 0 0 5 0 0;
0 1 0 7 0 0 0 0 0]

t = fill(0, (9,9))
t[1,1] = 5; t[1,5] = 6; t[1,7] = 9
t[2,3] = 3; t[2,8] = 7
t[4,2] = 7; t[4,8] = 1; t[4,9] = 4
t[5,3] = 8; t[5,5] = 5
t[6,4] = 2
t[7,1] = 2; t[7,7] = 6
t[8,4] = 3; t[8,7] = 5
t[9,2] = 1; t[9,4] = 7
"""

sudoku(t)

