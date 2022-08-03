model plantdemo

global {
	int number_of_plants <- 10;
	seasons season;
	//TODO:seperated variety of N according to plant position among grid aera
	//base_N_amount is the gross amount in the environment.
	float base_N_amount <- 10000.0;
	
	init {
	create plants number: number_of_plants;
	create seasons number: 1 {
		season <- self;
	}
	}
}

species plants {
	float N_amount;
	float aspect_size;
	float uptake_rate <- 0.0;
	float def_rate <- 0.0;
	float uptake_amount;
	float def_amount;
	
	init {
		N_amount <- 100.0;
		aspect_size <- 1.0;
		//TODO：limit the growth size of plant.
	}
	
	reflex plant_metabolism {
		do uptaken;
		do defoliation;
	}
	
	action uptaken {
		if (season.current_season = "winter") {
			uptake_rate <- 0.01 ;
			uptake_amount <- N_amount*uptake_rate;// uptaken equation here
			
		} else if (season.current_season = "spring") {
			uptake_rate <- 0.03 ;
			uptake_amount <- N_amount*uptake_rate;// uptaken equation here			
		} else if (season.current_season = "summer") {
			uptake_rate <- 0.05 ;
			uptake_amount <- N_amount*uptake_rate;// uptaken equation here
		} else if (season.current_season = "autumn") {
			uptake_rate <- 0.03 ;
			uptake_amount <- N_amount*uptake_rate;// uptaken equation here
		}
		N_amount <- N_amount + uptake_amount;
		base_N_amount <- base_N_amount - uptake_amount;
		aspect_size <- N_amount/100;
		//write "uptake1:"+N_amount;
		//write "total:"+base_N_amount;
	}
	action defoliation{
		if (season.current_season = "winter") {
			def_rate <- 0.008 ;
			def_amount <- N_amount *def_rate;// defoliation rate equation here
		} else if (season.current_season = "spring") {
			uptake_rate <- 0.01 ;
			def_amount <- N_amount *def_rate;// defoliation rate equation here			
		} else if (season.current_season = "summer") {
			uptake_rate <- 0.01 ;
			def_amount <- N_amount *def_rate;// defoliation rate equation here
		} else if (season.current_season = "autumn") {
			uptake_rate <- 0.02 ;
			def_amount <- N_amount *def_rate;//defoliation rate equation here
		}
		N_amount <- N_amount - def_amount;
		base_N_amount <- base_N_amount + def_amount;
		aspect_size <- N_amount/100;
		//write "def1:"+N_amount;
		//write "total:"+base_N_amount;
	}
	
	aspect default {
	draw circle(aspect_size) color: season.plant_color;
	}
}

species seasons {
	//seasonal variables
	int season_duration <- 600;
	int shift_cycle <- season_duration *4 update: season_duration * 4 + int(cycle - floor(season_duration / 2));
	list<string> season_list <- ["winter", "spring", "summer", "autumn"];
	string current_season <- "winter" update: season_list[(cycle div season_duration) mod 4];
	int current_day <- 0 update:  cycle mod season_duration;
	int shift_current_day <- 0 update: shift_cycle mod season_duration;
	int se <- 0 update: (shift_cycle div season_duration) mod 4;
	int next_se <- 1 update: (se + 1) mod 4;
	//weather variables
	string current_weather <- "norain"; //rainfall affects soil water content leading to change of plant metabolism rate.
	map<string, float> rain_prob <- ["winter"::0.2, "sping"::0.4, "summer"::0.6,"autumn"::0.4];
	float soil_water_content <- 10.0;
	float max_water_content <- 50.0;
	float min_water_content <- 5.0;
	//plant variables
	rgb plant_color <- plant_color_list[0];
	list<rgb> plant_color_list <- [rgb(150, 40, 27), rgb(134, 174, 83), rgb(30, 130, 76), rgb(192, 57, 43)];
	
	action change_color{
	plant_color <- blend(plant_color_list[se], plant_color_list[next_se], 1 - shift_current_day / season_duration);
	}
	
	reflex update {
		if flip(rain_prob[current_season]){
			do haverain;
		}else {
			do norain;
		}

		do change_color;
	}
	
	action haverain{
		//TODO:3D view of rain from z axis
		current_weather <- "haverain";
		if (soil_water_content < max_water_content){
		//should have proper equation here
		soil_water_content <- soil_water_content +1;
		write soil_water_content;
		}
	}
	action norain{
		current_weather <- "norain";
		if (soil_water_content > min_water_content){
		//should have proper equation here
		soil_water_content <- soil_water_content -1;
		write soil_water_content;
		}
	}
	//TODO: action affect_plant 
	//this action should be defined to effect plant uptake rate according to the soil water content.
}

grid base_catchment width: 30 height: 30 {
	init{
		color <- #green;
	}
}


experiment "my_GUI_xp" type:gui  {
	output{
		display my_display type: java2D {
			grid base_catchment border: #black;
			species plants aspect: default;
		}
	//TODO：3D view for the rain in the future?
	}
}
