
#!/bin/bash 

# The read command was in the wrong location. Putting it above the IF statement now allows for comparing user input AFTER entry
read -s -p "what's the secret code?" 
echo

secret='shhh' #Don't tell anyone! 
      
#if the user types in the correct secret, tell them they got it right!   
if [ "$secret" = "$REPLY" ]; then 
    echo "You got it right!" 
    correct=true 
else
    echo "You got it wrong :("   
    correct=false 
fi

case $correct in
    true)
        echo "you have unlocked the secret menu!" 
        #TODO: add a secret menu for people in the know. 
    ;; 

    *)
        echo "Go Away!" #people who get it wrong need to be told to go away! 
    ;; 
esac 