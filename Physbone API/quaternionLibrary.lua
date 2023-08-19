function quaternionFromAxisAngle(axis, angle)
    local halfAngle = angle * 0.5
    local sinHalfAngle = math.sin(halfAngle)
    local cosHalfAngle = math.cos(halfAngle)

    return {
        x = axis.x * sinHalfAngle,
        y = axis.y * sinHalfAngle,
        z = axis.z * sinHalfAngle,
        w = cosHalfAngle
    }
end

function rotateVectorByQuaternion(vector, quaternion)
    local qx = quaternion.x
    local qy = quaternion.y
    local qz = quaternion.z
    local qw = quaternion.w

    local x = vector.x
    local y = vector.y
    local z = vector.z

    local ix = qw * x + qy * z - qz * y
    local iy = qw * y + qz * x - qx * z
    local iz = qw * z + qx * y - qy * x
    local iw = -qx * x - qy * y - qz * z

    return {
        x = ix * qw + iw * -qx + iy * -qz - iz * -qy,
        y = iy * qw + iw * -qy + iz * -qx - ix * -qz,
        z = iz * qw + iw * -qz + ix * -qy - iy * -qx,
    }
end

function quaternionToEulerAngles(quat)
    local qw = quat.w
    local qx = quat.x
    local qy = quat.y
    local qz = quat.z

    local yaw = math.atan2(2 * (qw * qz + qx * qy), 1 - 2 * (qy * qy + qz * qz))
    local pitch = math.asin(2 * (qw * qy - qz * qx))
    local roll = math.atan2(2 * (qw * qx + qy * qz), 1 - 2 * (qx * qx + qy * qy))

    return pitch, yaw, roll
end