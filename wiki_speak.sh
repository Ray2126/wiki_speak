
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
	if [[ -z "`ls -A ./creations`" ]]
	then
		echo "No creations found. "
	else
		counter=1
		ls ./creations | sed 's/.mp4/\n/g' | sed '/^$/d' | sort | while read item ; do
			echo -n "[$counter]" 
			echo " $item"
			counter=$((counter+1))
		done
	fi
	
}

play_creations (){
	list_creations
	while [[ true ]]
	do		
		read -p "Which creation would you like to play? Enter the name (not the number) - " play_choice
		if [[ -f ./creations/"$play_choice.mp4" ]]
		then
			break
		else
			echo "That creation does not exist."
		fi
	done
	ffplay -autoexit ./creations/"$play_choice.mp4" &> /dev/null
	if [[ $? != 0 ]]
	then
		echo "Creation could not be played."
		echo ""
		read -n 1 -s -r -p "Press any key to return to main menu  "
		echo ""
		main_menu
	fi
	main_menu
}

delete_creations (){
	list_creations
	while [[ true ]]
	do		
		read -p "Which creation would you like to delete? Enter the name (not the number) - " delete_choice
		if [[ -f ./creations/"$delete_choice.mp4" ]]
		then
			read -p "You are going to delete $delete_choice. Are you sure [y/n] - " delete_sure
			if [[ $delete_sure == "y" ]]
			then
				rm -f ./creations/"$delete_choice.mp4"
				echo "Delete Successful!"
				break
			fi
		else
			echo "That creation does not exist."
		fi
	done
	main_menu
}

create_creations (){
	get_wiki_search
	
	#display sentences to terminal
	counter=1
	echo $wiki_search | sed 's/[.]/&\n/g' | sed '/^$/d' | while read sentence ; do
		echo -n "[$counter]" 
		echo $sentence | tee -a temp.txt	
		counter=$((counter+1))
	done 
	
	while [[ true ]]
	do
		read -p "How many sentences would you like in the final creation? " num_sentences
		
		#check if number entered is valid
		if ! [[ "$num_sentences" =~ ^[0-9]+$ ]]
		then
			echo "Please enter a valid number."
		else
			if (($num_sentences >= 1 && $num_sentences <= `wc -l < temp.txt`))
			then
				break
			else
				echo "Please enter a valid number."
			fi
		fi
	done
	
	
	echo "`head -$num_sentences < temp.txt`" > temp.txt
	cat temp.txt | text2wave -o speech.wav
	
	while [[ true ]]
	do
		read -p "Enter a name for this creation - " creation_name
		if [[ -f ./creations/"$creation_name.mp4" ]]
		then
			echo "File already exists."
			read -p "Would you like to overwrite? [y/n] " do_overwrite
			if [[ $do_overwrite == "y" ]]
			then
				rm -f ./creations/"$creation_name.mp4"
				break
			fi
		else
			break
		fi
	done
	
	echo -n "Creating $creation_name. Please wait...  "
	
	#create the creation
	vid_length=`soxi -D speech.wav`
	ffmpeg -f lavfi -i color=c=blue:s=320x240 -t "${vid_length}" -vf "drawtext=fontsize=30:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text='$searched_word'" video.mp4 &> /dev/null
	if [[ $? == 0 ]]
	then
		ffmpeg -i video.mp4 -i speech.wav ./creations/"${creation_name}".mp4 &> /dev/null
		if [[ $? == 0 ]]
		then
			echo "Success!"
		else
			echo "Failed!" >&2
		fi
	else 
		echo "Failed!" >&2
	fi

	
	
	#remove temporary files
	rm -f temp.txt
	rm -f speech.wav
	rm -f video.mp4
	
	echo ""
	read -n 1 -s -r -p "Press any key to return to main menu  "
	echo ""
	
	main_menu
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

#make the subfolder for creations
mkdir -p creations
main_menu