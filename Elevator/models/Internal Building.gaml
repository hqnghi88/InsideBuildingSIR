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
	int elevator_capacity <- 5;

	init {
		loop i from: min_stage to: max_stage {
			create Wall from: idecaf_shp {
				stage <- i;
				create People number: 10 {
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
	float my_speed <- 20 #m;
	int stage <- 0;
	int in_elevator <- 0;

	reflex stay when: target = nil {
		if flip(0.05) {
			target <- any_location_in(world.shape);
			my_speed <- (20 + rnd(30)) #m;
		}

	}

	reflex move when: target != nil {
		do goto target: target speed: my_speed; //on: road_network;
		//		do wander speed: 20 #m;
		if (location = target) {
			target <- nil;
		}

	}

	reflex infect when: is_infected {
		ask (People where (each.stage = self.stage)) at_distance 10 #m {
			if flip(0.1) {
				is_infected <- true;
			}

		}

	}

	aspect circle {
		draw circle(10) color: is_infected ? #red : #green;
	}

	aspect default {
	//		if target != nil {
		draw obj_file("../includes/people.obj", 90::{-1, 0, 0}) size: 25 at: location + {0, 0, stage * stage_height + 35} rotate: heading - 90 color: is_infected ? #red : #green;
		//		}

	}

}

species Elevator {
	int zz <- 0;
	int stage_src <- min_stage;
	int stage_dest <- min_stage;
	list<People> cand <- [];

	reflex called when: flip(0.05) and stage_src = stage_dest {
		stage_dest <- rnd(max_stage);
		cand <- rnd(elevator_capacity) among (People where (each.stage = stage_src));
	}

	reflex moving when: stage_src != stage_dest {
		if (stage_dest > stage_src) {
			zz <- zz + 50;
		}

		if (stage_dest < stage_src) {
			zz <- zz - 50;
		}

		if (zz = stage_dest * stage_height) {
			ask cand{
				stage<-myself.stage_dest;
			}
			stage_src <- stage_dest;
		}

	}

	aspect default {
		draw cube(200) at: {location.x, location.y, zz} color: #darkgray;
	}

}

species Wall {
	int stage <- 0;

	aspect default {
		draw shape at: location + {0, 0, stage * stage_height} color: #darkgray depth: 50;
	}

}

species Gate {

	aspect default {
		draw shape + 1 color: #darkgray depth: 10;
	}

}

experiment InsideBuilding type: gui {
	output {
		display "sim" type: opengl background:#lightgray {
			species Wall;
			species Gate;
			species Elevator;
			species People;
		}

	}

}
