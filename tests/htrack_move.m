function [] = htrack_move(theta)

num_phalanges = 16;
for i = 1:num_phalanges + 2
	phalanges[i].local = phalanges[i].init_local;
	}

	vector<float> rotateX(num_thetas, 0); // flexion
	vector<float> rotateZ(num_thetas, 0); // abduction
	vector<float> rotateY(num_thetas, 0); // twist
	vector<float> globals(num_thetas, 0); // pose

	for (size_t i = 0; i < num_thetas; ++i) {
		if (dofs[i].phalange_id < num_phalanges && dofs[i].type == ROTATION_AXIS) {
			if (dofs[i].axis == Vec3f(1, 0, 0))
				rotateX[i] = theta[i];
			else if (dofs[i].axis == Vec3f(0, 1, 0))
				rotateY[i] = theta[i];
			else if (dofs[i].axis == Vec3f(0, 0, 1))
				rotateZ[i] = theta[i];
			else
				cout << "wrong axis" << endl;

		}
		else
			globals[i] = theta[i];
	}

	//transform joints separately
	transform_joints(globals); // pose	
	transform_joints(rotateX); // flexion
	transform_joints(rotateZ); // abduction
	transform_joints(rotateY); // twist
}