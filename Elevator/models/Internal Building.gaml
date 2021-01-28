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
	int max_stage <- 3;

	init {
		loop i from: min_stage to: max_stage {
			create Wall from: idecaf_shp {
				stage <- i;
			}

		}

		create Gate from: gates_shp {
			create Elevator {
				location <- myself.location;
			}

		}

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

		if (zz = stage_dest * 200) {
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
		draw shape + 1 at: {location.x, location.y, stage * 200} color: #darkgray depth: 50;
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
		}

	}

}
