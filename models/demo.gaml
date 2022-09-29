model demo

global {
	
	int max_number_plants <- 100;
	rgb plant_color <- rgb(0,125,0);
	float average_temperature;
	float lightening_prob;
	float rain_amount;
	float ground_depth;
	float transp;
	
	init {
	create plants number: max_number_plants;
	loop i from: 0 to: 14 {
		loop m from:0 to: 14{
			ask ground grid_at {i,m} {
			//	if (self.depth < 5.0){
					self.ammonium <- rnd(18.0);
					self.nitrate <- rnd(1.0);
					self.water_level <- rnd(10.0);
					//organic matters etc.
					self.current_color <- blend(self.color_list[0], self.color_list[1], self.water_level /self.pool);
			//	}
			}
			ask layer1 grid_at {i,m} {
					self.ammonium <- rnd(18.0);
					self.nitrate <- rnd(1.0);
					self.water_level <- rnd(10.0);
					//organic matters etc.
					self.current_color <- blend(self.color_list[0], self.color_list[1], self.water_level /self.pool);
			}
		}
	}
	}

	reflex update{
		if (ground_depth > 5.0){
				transp <- 0.5;
			}else {
				transp <- 0.0;
			}
		ask plants {
		}
		ask ground {
			self.current_color<- blend(self.color_list[0], self.color_list[1], self.ammonium /self.pool);
			self.color <- self.current_color;
		}
		ask layer1 {
			self.color <- self.current_color;
		}
	}
}
species plants {
	float max_canopy_size;
	// max_canopy_size is the max canopy size of one plant. this should be considered when microbe agents are included.
	float canopy_diameter;
	float average_growth <- 0.02;
	// average_growth represents the absorption of N.
	float distance_between <- 2.0;
	
	init {
	canopy_diameter <- 0.5;
	max_canopy_size <- 2.5;
	}
	
	reflex plant_metabolism {
		if (canopy_diameter <= max_canopy_size) {
				do grow;
		}
	}
	
	action grow {
		canopy_diameter <- self.canopy_diameter + average_growth;
	}

	aspect default {
		if (canopy_diameter <= max_canopy_size) {
			draw circle(canopy_diameter) color: plant_color;	
		}else {
			draw circle(max_canopy_size) color: plant_color;
		}
		ask plants at_distance(max_canopy_size){
			do die;
		}
	}
}


grid layer1 parent: ground width: 15 height: 15 {
	init{
		pool <- 18.0;
		color_list <- [rgb(0, 255, 0), rgb(255, 255, 255)];
	}
}

grid ground width: 15 height: 15 {
	//TODO:seperated variety of N according to plant position among grid aera
	//base_N_amount is the gross amount in the environment.
	float depth;
	float water_level;
	float organic_N;
	float ammonium;
	float nitrate;
	float organic_C;
	list<rgb> color_list;
	float pool;
	rgb current_color;
	float transp<- 0.0;
	
	action water_discharge {
		
	}

	init{
		pool <- 18.0;
		color_list <- [rgb(0, 0, 255), rgb(255, 255, 255)];
	}
	
}



experiment "my_GUI_xp" type:gui  {
	parameter "Visible depty:" var: ground_depth <- float(0.0::50.0) category: "Ground layer";
	output{
		display my_display type: java2D {
				grid ground  border: #black;
				grid layer1  transparency:transp border: #black;
				species plants aspect: default;
			}
	//TODO：3D view for the rain in the future?
	}
}
