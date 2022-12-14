using Printf
using LinearAlgebra
using DelimitedFiles
using Quaternions

#CODE MADE BY DAVID BOCES OBIS

global axis_norm

function mat_to_axis_angle(mat)
    #first, we find the angle:
    angle = acosd((tr(mat)-1)/2)

    #then, we find the axis:
    V = (mat-mat')/(2*sind(angle))
    v = [V[3,2]; V[1,3]; V[2,1]]

    #we return the angle in degrees
    return angle, v
end

A = [-0.428571 -0.613072 -0.663679;0.898786 -0.214286 -0.382446;0.0922502 -0.760411 0.642857]
println(mat_to_axis_angle(A))

global q2

q = quat(1/2,0.18898,0.37796,0.75593)

function quat_to_axis_angle(q3)
    angle3 = 2*acosd(q3.s);
    axis_norm[1] = q3.v1/sind(angle3/2)
    axis_norm[2] = q3.v2/sind(angle3/2)
    axis_norm[3] = q3.v3/sind(angle3/2)

    return angle3, axis_norm
end

println(quat_to_axis_angle(q))

function quat_to_mat(q)
    global matQuat = [((q.s)^2 + (q.v1)^2 - (q.v2)^2 - (q.v3)^2) (2*(q.v1)*(q.v2) - 2*(q.s)*(q.v3)) (2*(q.v1)*(q.v3) + 2*(q.s)*(q.v2));
            (2*(q.v1)*(q.v2) + 2*(q.s)*(q.v3)) ((q.s)^2 - (q.v1)^2 + (q.v2)^2 - (q.v3)^2) (2*(q.v2)*(q.v3) - 2*(q.s)*(q.v1));
            (2*(q.v1)*(q.v3) - 2*(q.s)*(q.v2)) (2*(q.v2)*(q.v3) + 2*(q.s)*(q.v1)) ((q.s)^2 - (q.v1)^2 - (q.v2)^2 + (q.v3)^2)]

    return matQuat
end

q2 = quat(1/sqrt(2), 0, 0, 1/sqrt(2))

println(quat_to_mat(q2))

function focal_camera(cameraMatrixInv, focus, point)
    projMat=[focus 0 0 0; 0 focus 0 0;  0 0 1 0]

    pointHomo = vcat(point, [1])

    finalPoint=projMat*cameraMatrixInv*pointHomo

    finalPointHomo = [finalPoint[1]/finalPoint[3];finalPoint[2]/finalPoint[3]; finalPoint[3]/finalPoint[3]]

    return finalPointHomo
end

#println(focal_camera([0 1 0;-1 0 0; 0 0 1], 1/10,[278.40466;1113.61866;69.60116] ))
