shader_type canvas_item;

group_uniforms ShaderParameters.radian_rotation;
// set x,y,z between 0 and 2pi
uniform float x_rad: hint_range(0, 6.283185307);
uniform float y_rad: hint_range(0, 6.283185307);
uniform float z_rad: hint_range(0, 6.283185307);




group_uniforms ShaderParameters.perspective_factor;
uniform float depth_factor: hint_range(0.1, 10.0); // Depth scaling factor to control how strong the perspective effect is

vec4 quat_from_angle_axis(float angle, vec3 axis)
{
	vec3 normalized_axis = normalize(axis);
	vec4 quaternion;
	
	
	quaternion.x = normalized_axis.x * sin(angle/2.0);
	quaternion.y = normalized_axis.y * sin(angle/2.0);
	quaternion.z = normalized_axis.z * sin(angle/2.0);
	quaternion.w = cos(angle/2.0);
	
	return quaternion;
}

// combine the x, y and z rotation
vec4 quat_multiply(vec4 q1, vec4 q2) {
    vec4 result;
    result.x = q1.w * q2.x + q1.x * q2.w + q1.y * q2.z - q1.z * q2.y;
    result.y = q1.w * q2.y - q1.x * q2.z + q1.y * q2.w + q1.z * q2.x;
    result.z = q1.w * q2.z + q1.x * q2.y - q1.y * q2.x + q1.z * q2.w;
    result.w = q1.w * q2.w - q1.x * q2.x - q1.y * q2.y - q1.z * q2.z;
    return result;
}

vec3 apply_rotation(vec3 v, vec4 q) {
    vec4 v_quat = vec4(v, 0.0);
    vec4 q_conjugate = vec4(-q.x, -q.y, -q.z, q.w);
    
    vec4 rotated = quat_multiply(quat_multiply(q, v_quat), q_conjugate);
    return rotated.xyz;
}

void vertex() {
	// Called for every vertex the material is visible on.
	vec4 q_x = quat_from_angle_axis(x_rad, vec3(1.0, 0.0, 0.0)); 
    vec4 q_y = quat_from_angle_axis(y_rad, vec3(0.0, 1.0, 0.0)); 
    vec4 q_z = quat_from_angle_axis(z_rad, vec3(0.0, 0.0, 1.0)); 

    vec4 q_combined = quat_multiply(quat_multiply(q_z, q_y), q_x);

	// apply the rotations to the 2D vertex
    vec3 pos = vec3(VERTEX.xy, depth_factor);
    pos = apply_rotation(pos, q_combined);

	pos.x /= (1.0 + pos.z); // Perspective scaling
    pos.y /= (1.0 + pos.z); // Perspective scaling
	
    VERTEX = pos.xy;
}

void fragment() {
	// Called for every pixel the material is visible on.

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
