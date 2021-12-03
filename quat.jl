using Printf
using LinearAlgebra
using DelimitedFiles
using Quaternions

#-------------------------------------------------------------------- EXERCISE 3.1
angle_input = 90 #degrees
axis_input = [0;1;2] #axis z
global axis_norm



function axis_angle_to_mat(axis, angle)
    #first, we normalize the axis
    modul = sqrt(axis[1]*axis[1] + axis[2]*axis[2] + axis[3]*axis[3])

    global axis_norm = axis/modul

    Z = [0 -axis_norm[3] axis_norm[2];
         axis_norm[3] 0 -axis_norm[1];
        -axis_norm[2] axis_norm[1] 0]

    #formula Rodrigues
    R = I + sind(angle)*Z + (1-cosd(angle))*(Z^2)
    #just above, we multiply pi/180 to the angle (in degrees) to obtain the angle in radians
    #so julia can do the operation we want

    #next, we will check if R is a rotation matrix: R*R'=I and det(R)=1
    #For this comprobation, we needed to round R*R' and det(R). That's because much times
    #the result was 0.999999 and not 1
    if (round.(R*R')== I && round(det(R))==1)
        #we return the rotation matrix
        return R
    else
        print("R = ", R, "\nis NOT a rotation matrix\n")
        println("R*R'= ", round.(R*R'))
        println("det(R)= ", round(det(R)))
    end
end

mat = axis_angle_to_mat(axis_input, angle_input)

println("The rotation matrix composed of AXIS = ", axis,
 " normalized as ", axis_norm, " and ANGLE = ", angle,
  " degrees is R = ", mat)

function mat_to_axis_angle(mat)
    #first, we find the angle:
    angle = acosd((tr(mat)-1)/2)

    #then, we find the axis:
    V = (mat-mat')/(2*sind(angle))
    v = [V[3,2]; V[1,3]; V[2,1]]

    #we return the angle in degrees
    return angle, v
end

println()
println("The rotation matrix R = ", mat,
" has the following ANGLE (in degrees) and unit AXIS: \n", mat_to_axis_angle(mat))

q = quat(1,0,0,0)

global q2

function axis_angle_to_quat(axis, angle)
    global q2
    #first, we normalize the axis
    modul = sqrt(axis[1]*axis[1] + axis[2]*axis[2] + axis[3]*axis[3])

    global axis_norm = axis/modul

    q2 = quat(cosd(angle/2), sind(angle/2)*axis_norm[1], sind(angle/2)*axis_norm[2], sind(angle/2)*axis_norm[3])

    return q2
end

println()
println("The Quaternion composed of AXIS = ", axis,
 " normalized as ", axis_norm, " and ANGLE = ", angle,
  " degrees is q = ", axis_angle_to_quat(axis_norm, angle_input))

function quat_to_axis_angle(q3)
    angle3 = 2*acosd(q3.s);
    axis_norm[1] = q3.v1/sind(angle3/2)
    axis_norm[2] = q3.v2/sind(angle3/2)
    axis_norm[3] = q3.v3/sind(angle3/2)

    return angle, axis_norm
end

println()
println("The Quaternion q = ", q2,
" has the following ANGLE (in degrees) and unit AXIS: \n", quat_to_axis_angle(q2))

global matQuat

function quat_to_mat(q)
    global matQuat = [((q.s)^2 + (q.v1)^2 - (q.v2)^2 - (q.v3)^2) (2*(q.v1)*(q.v2) - 2*(q.s)*(q.v3)) (2*(q.v1)*(q.v3) + 2*(q.s)*(q.v2));
            (2*(q.v1)*(q.v2) + 2*(q.s)*(q.v3)) ((q.s)^2 - (q.v1)^2 + (q.v2)^2 - (q.v3)^2) (2*(q.v2)*(q.v3) - 2*(q.s)*(q.v1));
            (2*(q.v1)*(q.v3) - 2*(q.s)*(q.v2)) (2*(q.v2)*(q.v3) + 2*(q.s)*(q.v1)) ((q.s)^2 - (q.v1)^2 - (q.v2)^2 + (q.v3)^2)]

    return matQuat
end

println()
println("The Quaternion q = ", q, " as a rotation matrix R = ", quat_to_mat(q))

quat_to_mat(q)

function mat_to_quat(mat)
    #first, we find the angle:
    angle2 = acosd((tr(mat)-1)/2)

    if (angle2 != 0)
        #then, we find the axis:
        V = (mat-mat')/(2*sind(angle2))
        v = [V[3,2]; V[1,3]; V[2,1]]

        q3 = quat(cosd(angle2/2), sind(angle2/2)*v[1], sind(angle2/2)*v[2], sind(angle2/2)*v[3])

        return q3
    else
        return "THIS ROTATION MATRIX [IDENTITY MATRIX] HAS NO AXIS. ITS ROTATION ANGLE IS 0 + 360*K [BEING K AN ENTER]. FOR THE RESULT THIS MATRIX HAS NO QUATERNION FORM."
    end

end

println()
println("The rotation matrix R = ", matQuat,
" has the following Quaternion q: \n", mat_to_quat(matQuat))
