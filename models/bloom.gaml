/**
* Name: bloom
* Based on the internal empty template. 
* Author: zhujiangning
* Tags: 
*/


model burst_the_baloon

global{
    float worldDimension <- 5#m;
    geometry shape <- square(worldDimension);
    int nbBaloonDead <- 0;

    reflex buildBaloon when: (flip(0.1)) {
    create balloon number: 1;
    }
    
    reflex endSimulation when: nbBaloonDead>10 {
    do pause;
    }
}

species balloon {
    float balloon_size;
    rgb balloon_color;
    
    init {
    balloon_size <- 0.1;
    balloon_color <- rgb(rnd(255),rnd(255),rnd(255));
    }

    reflex balloon_grow {
    balloon_size <- balloon_size + 0.01;
    if (balloon_size > 0.5) {
        if (flip(0.2)) {
        do balloon_burst;
        }
    }
    }
    
    float balloon_volume (float diameter) {
    float exact_value <- 2/3 * #pi * diameter^3;
    float round_value <- round(exact_value*1000)/1000;
    return round_value;
    }
    
    action balloon_burst {
    write "the baloon is dead !";
    nbBaloonDead <- nbBaloonDead + 1;
    do die;
    }
    
    aspect balloon_aspect {
    draw circle(balloon_size) color: balloon_color;
    draw string(balloon_volume(balloon_size)) color: #black;
    }
}

experiment my_experiment type: gui {
    output {
    display myDisplay {
        species balloon aspect: balloon_aspect;
    }
    }
}