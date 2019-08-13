
#!/bin/bash

main_menu (){
	echo "====================================================="
	echo "Welcome to the Wiki-Speak Authoring Tool"
	echo "====================================================="
	echo "Please select from one of the following options:"
	echo ""
	echo "	(l)ist existing creations"
	echo "	(p)lay an existing creation"
	echo "	(d)elete an existing creation"
	echo "	(c)reate a new creation"
	echo "	(q)uit authoring tool"
	echo ""
	
	while [[ true ]]
	do
		read -p "Enter a selection [l/p/d/c/q]: " selection
		selection=${selection,,}
		if [ "$selection" == "l" ]
		then
			list_creations
		elif [ "$selection" == "p" ]
		then
			play_creations
		elif [ "$selection" == "d" ]
		then
			delete_creations
		elif [ "$selection" == "c" ]
		then
			create_creations
		elif [ "$selection" == "q" ]
		then
			echo "quitting"
			exit 0
		fi
	done
}

list_creations (){
	echo "Listing was called"
}

play_creations (){
	echo "playing was called"
}

delete_creations (){
	echo "deleting was called"
}

create_creations (){
	echo "creating was called"
	get_wiki_search
	counter=1
	echo $wiki_search | sed 's/[.]/&\n/g' | sed '$d' | while read sentence ; do
		echo -n "[$counter]" 
		echo $sentence | tee -a temp.txt
		counter=$((counter+1))
	done 
	
	
}

get_wiki_search (){
	while [[ true ]]
	do
		read -p "Enter what you would like to search - " searched_word
		wiki_search=`wikit $searched_word`
		if [[ $wiki_search == "$searched_word not found :^(" ]]
		then
			echo "No wikipedia page found for $searched_word."
			read -p "Would you like to exit to main menu [y/n]: " exit_to_menu
			if [[ $exit_to_menu == "y" ]]
			then
				main_menu
			fi
			
		else
			return
		fi
	done
}

main_menu