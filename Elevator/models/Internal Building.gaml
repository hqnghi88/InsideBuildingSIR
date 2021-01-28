/**
* Name: NewModel
* Based on the internal skeleton template. 
* Author: hqngh
* Tags: 
*/
model NewModel

global {
	shape_file idecaf_shp <- shape_file("../includes/ground.shp");
	shape_file gates_shp <- shape_file("../includes/gates.shp");
	geometry shape <- envelope(idecaf_shp);
	int min_stage <- 0;
	int max_stage <- 2;
	int stage_height <- 300;
	int nb_infected_init <- 1;

	init {
		loop i from: min_stage to: max_stage {
			create Wall from: idecaf_shp {
				stage <- i;
				create People number: 100 {
					stage <- i;
				}

			}

		}

		create Gate from: gates_shp {
			create Elevator {
				location <- myself.location;
			}

		}

		ask nb_infected_init among People {
			is_infected <- true;
		}

	}

}

species People skills: [moving] {
	float speed <- (2 + rnd(3)) #km / #h;
	bool is_infected <- false;
	point target;
	int stage <- 0;

	reflex stay when: target = nil {
		if flip(0.05) {
			target <- any_location_in(world.shape);
		}

	}

	reflex move when: target != nil {
			do goto target:target ;//on: road_network;
//		do wander speed: 10 #m;
		if (location = target) {
			target <- nil;
		}

	}

	reflex infect when: is_infected {
		ask (People where (each.stage=self.stage)) at_distance 10 #m {
			if flip(0.05) {
				is_infected <- true;
			}

		}

	}

	aspect circle {
		draw circle(10) color: is_infected ? #red : #green;
	}

	aspect default {
	//		if target != nil {
		draw obj_file("../includes/people.obj", 90::{-1, 0, 0}) size: 25 at: location + {0, 0, stage * stage_height + 25} rotate: heading - 90 color: is_infected ? #red : #green;
		//		}

	}

}

species Elevator {
	int zz <- 0;
	int stage_src <- min_stage;
	int stage_dest <- min_stage;

	reflex called when: flip(0.01) and stage_src = stage_dest {
		stage_dest <- rnd(max_stage);
	}

	reflex moving when: stage_src != stage_dest {
		if (stage_dest > stage_src) {
			zz <- zz + 10;
		}

		if (stage_dest < stage_src) {
			zz <- zz - 10;
		}

		if (zz = stage_dest * stage_height) {
			stage_src <- stage_dest;
		}

	}

	aspect default {
		draw cube(100) at: {location.x, location.y, zz} color: #darkgray;
	}

}

species Wall {
	int stage <- 0;

	aspect default {
		draw shape + 1 at: {location.x, location.y, stage * stage_height} color: #darkgray depth: 50;
	}

}

species Gate {

	aspect default {
		draw shape + 1 color: #darkgray depth: 10;
	}

}

experiment InsideBuilding type: gui {
	output {
		display "sim" type: opengl {
			species Wall;
			species Gate;
			species Elevator;
			species People;
		}

	}

}
