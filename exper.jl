#  Steffen Zahn

import Base.+
import Base.-
import Base.*
import Base./
import Base.zero
import Base.iszero
import Base.one
import Base.inv
import Base.isnan
import Base.isinf
import Base.abs
import Base.abs2
import Random
import Base.sin
import Base.cos
import Base.tan
import Base.cot
using Images
#using ColorTypes
#using Match

struct Quaternion{T<:AbstractFloat}
    w::T  # real part
    x::T  # i component  
    y::T  # j component
    z::T  # k component
end

# Addition operation - much cleaner!
function Base.:zero(q1::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(zero(q1.w), zero(q1.x), zero(q1.y), zero(q1.z))
end

# For mixed types
function Base.:zero(q1::Quaternion)
    T = promote_type(typeof(q1.w))
    return Quaternion{T}(zero(q1.w), zero(q1.x), zero(q1.y), zero(q1.z))
end

function Base.:iszero(q1::Quaternion{T})::Bool where {T<:AbstractFloat}
    return iszero(q1.w) && iszero(q1.x) && iszero(q1.y) && iszero(q1.z)
end

# Addition operation - much cleaner!
function Base.:+(q1::Quaternion{T}, q2::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(q1.w + q2.w, q1.x + q2.x, q1.y + q2.y, q1.z + q2.z)
end

# For mixed types
function Base.:+(q1::Quaternion, q2::Quaternion)
    T = promote_type(typeof(q1.w), typeof(q2.w))
    return Quaternion{T}(q1.w + q2.w, q1.x + q2.x, q1.y + q2.y, q1.z + q2.z)
end

function Base.:-(q1::Quaternion{T}, q2::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(q1.w - q2.w, q1.x - q2.x, q1.y - q2.y, q1.z - q2.z)
end

function Base.:-(q1::Quaternion, q2::Quaternion)
    T = promote_type(typeof(q1.w), typeof(q2.w))
    return Quaternion{T}(q1.w - q2.w, q1.x - q2.x, q1.y - q2.y, q1.z - q2.z)
end

# Quaternion scalar multiplication (both orders)
function Base.:*(q::Quaternion{T}, y::AbstractFloat)::Quaternion{T} where {T<:AbstractFloat}
    local yy = convert(T,y)
    return Quaternion(q.w*yy, q.x*yy, q.y*yy, q.z*yy)
end
function Base.:*(y::AbstractFloat, q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    local yy = convert(T,y)
    return Quaternion(q.w*yy, q.x*yy, q.y*yy, q.z*yy)
end
function Base.:*(q::Quaternion{T}, y::T)::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(q.w*y, q.x*y, q.y*y, q.z*y)
end
function Base.:*(y::T, q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(q.w*y, q.x*y, q.y*y, q.z*y)
end

# Hamilton (quaternion) product
function Base.:*(a::Quaternion{T}, b::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z,
                      a.w*b.x + a.x*b.w + a.y*b.z - a.z*b.y,
                      a.w*b.y - a.x*b.z + a.y*b.w + a.z*b.x,
                      a.w*b.z + a.x*b.y - a.y*b.x + a.z*b.w)
end

function Base.:*(a::Quaternion, b::Quaternion)
    T = promote_type(typeof(a.w), typeof(b.w))
    aT = Quaternion{T}(convert(T,a.w), convert(T,a.x), convert(T,a.y), convert(T,a.z))
    bT = Quaternion{T}(convert(T,b.w), convert(T,b.x), convert(T,b.y), convert(T,b.z))
    return aT * bT
end

# Quaternion times 4x4 matrix (linear transform)
function Base.:*(q::Quaternion{T}, m::Matrix{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(q.w*m[1,1]+q.x*m[2,1]+q.y*m[3,1]+q.z*m[4,1],
                      q.w*m[1,2]+q.x*m[2,2]+q.y*m[3,2]+q.z*m[4,2],
                      q.w*m[1,3]+q.x*m[2,3]+q.y*m[3,3]+q.z*m[4,3],
                      q.w*m[1,4]+q.x*m[2,4]+q.y*m[3,4]+q.z*m[4,4])
end

# Dot product and norms
function ⋅(a::Quaternion{T}, b::Quaternion{T})::T where {T<:AbstractFloat}
    return a.w*b.w + a.x*b.x + a.y*b.y + a.z*b.z
end
function norm(q::Quaternion{T})::T where {T<:AbstractFloat}
    return sqrt(q ⋅ q)
end
function abs(q::Quaternion{T})::T where {T<:AbstractFloat}
    return sqrt(q ⋅ q)
end
function abs2(q::Quaternion{T})::T where {T<:AbstractFloat}
    return q ⋅ q
end
function normalize(a::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    local n = norm(a)
    if n == zero(n)
        return a
    end
    return (one(n)/n) * a
end

function conj(q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(q.w, -q.x, -q.y, -q.z)
end

function Base.inv(q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    local denom = q.w*q.w + q.x*q.x + q.y*q.y + q.z*q.z
    return (one(denom)/denom) * conj(q)
end

function isnan(q::Quaternion{T})::Bool where {T<:AbstractFloat}
    return isnan(q.w) || isnan(q.x) || isnan(q.y) || isnan(q.z)
end
function isinf(q::Quaternion{T})::Bool where {T<:AbstractFloat}
    return isinf(q.w) || isinf(q.x) || isinf(q.y) || isinf(q.z)
end

# Analytic quaternion trigonometric functions
function sin(q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    a  = q.w
    vx = q.x
    vy = q.y
    vz = q.z

    b2 = vx*vx + vy*vy + vz*vz
    b  = sqrt(b2)

    if b == zero(T)
        # Purely real quaternion: reduce to real sine
        return Quaternion(sin(a), zero(T), zero(T), zero(T))
    else
        sa = sin(a)
        ca = cos(a)
        sb = sinh(b)
        cb = cosh(b)

        # Vector coefficient: (cos(a)*sinh(b))/b
        k  = ca * sb / b

        return Quaternion(sa * cb,
                          vx * k,
                          vy * k,
                          vz * k)
    end
end

function cos(q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    a  = q.w
    vx = q.x
    vy = q.y
    vz = q.z

    b2 = vx*vx + vy*vy + vz*vz
    b  = sqrt(b2)

    if b == zero(T)
        # Purely real quaternion: reduce to real cosine
        return Quaternion(cos(a), zero(T), zero(T), zero(T))
    else
        sa = sin(a)
        ca = cos(a)
        sb = sinh(b)
        cb = cosh(b)

        # Vector coefficient: -(sin(a)*sinh(b))/b
        k  = -sa * sb / b

        return Quaternion(ca * cb,
                          vx * k,
                          vy * k,
                          vz * k)
    end
end

function tan(q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return sin(q) / cos(q)
end

function cot(q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return cos(q) / sin(q)
end

# one and setindex for Quaternion
function Base.one(q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(one(q.w), zero(q.x), zero(q.y), zero(q.z))
end

function setindex(q::Quaternion{T}, v::T, index::Int64)::Quaternion{T} where {T<:AbstractFloat}
    index==1 && return Quaternion(v,q.x,q.y,q.z)
    index==2 && return Quaternion(q.w,v,q.y,q.z)
    index==3 && return Quaternion(q.w,q.x,v,q.z)
    return Quaternion(q.w,q.x,q.y,v)
end

function mySum(q::Quaternion{T})::T where {T<:AbstractFloat}
    return q.w + q.x + q.y + q.z
end
function myAbs(q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(abs(q.w), abs(q.x), abs(q.y), abs(q.z))
end

function myFunc(q::Quaternion{T})::T where {T<:AbstractFloat}
    return abs(q.w*q.w - q.x*q.x) + abs(q.y*q.y - q.z*q.z)
end

# Unary negation for Quaternion
function Base.:-(q::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(-q.w, -q.x, -q.y, -q.z)
end

# Quaternion division
function Base.:/(a::Quaternion{T}, b::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return a * inv(b)
end

# For mixed-type quaternions, promote and divide
function Base.:/(a::Quaternion, b::Quaternion)
    T = promote_type(typeof(a.w), typeof(b.w))
    aT = Quaternion{T}(convert(T,a.w), convert(T,a.x), convert(T,a.y), convert(T,a.z))
    bT = Quaternion{T}(convert(T,b.w), convert(T,b.x), convert(T,b.y), convert(T,b.z))
    return aT / bT
end

function wave(x::T, p::T)::T where {T<:AbstractFloat}
    local xx = x / p
    local a = convert(T,floor(Int64,xx))
    local m = a + convert(T,0.5)
    local b = a + convert(T,1.0)
    if xx < m
        local t = xx - a
        return t*t
    else
        local t = b - xx
        return t*t
    end
end

function wave2(x::T, p::T)::T where {T<:AbstractFloat}
    local xx = x / p
    local aint64 = floor(Int64,xx)
    local odd = aint64 % 2 != 0
    local a = convert(T,aint64)
    local m = a + convert(T,0.5)
    local b = a + convert(T,1.0)
    if xx < m
        local t = xx - a
        return odd ? - t*t : t*t
    else
        local t = b - xx
        return odd ? - t*t : t*t
    end
end

function wave2(q::Quaternion{T}, p::Quaternion{T}, o::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return Quaternion(wave2(q.w, abs(p.w)+abs(o.w)),
                      wave2(q.x, abs(p.x)+abs(o.x)),
                      wave2(q.y, abs(p.y)+abs(o.y)),
                      wave2(q.z, abs(p.z)+abs(o.z)))
end
function wave2(x::Quaternion{T}, p::Quaternion{T})::Quaternion{T} where {T<:AbstractFloat}
    return wave2(x, p, Quaternion(zero(T),zero(T),zero(T),zero(T)))
end


# Global palette cache
const PALETTE_CACHE = Dict{Tuple{Int64,Int64}, Tuple{Vector{RGB},Int64}}()

function initPalette(;colorScheme::Int64=0,
                     colorRepetitions::Int64=1)::Tuple{Vector{RGB},Int64}

    cache_key = (colorScheme, colorRepetitions)
    
    if haskey(PALETTE_CACHE, cache_key)
        return PALETTE_CACHE[cache_key]
    end

    local colorSet=div(colorScheme,6)
    colorScheme -= 6*colorSet
    local colorstepsOneColor=256
    local colorsteps=6*colorRepetitions*colorstepsOneColor
    local gray = 1.0/convert(Float64,colorstepsOneColor)
    local colors=Array{RGB}(UndefInitializer(),colorsteps)
    for ii in 1:colorstepsOneColor
        local scaledGray=gray*ii
        local baseColor1=RGB(0.0,0.0,0.0)
        local baseColor2=baseColor1
        local baseColor3=baseColor1
        local color1
        local color2
        local color3
        if colorSet == 0
            baseColor1=RGB(scaledGray,0.0,0.7*scaledGray)
            baseColor2=RGB(0.0,scaledGray,0.8*scaledGray)
            baseColor3=RGB(0.4*scaledGray,0.0,scaledGray)
        elseif colorSet == 1
            baseColor1=RGB(scaledGray,0.0,0.4*scaledGray)
            baseColor2=RGB(0.635294*scaledGray,scaledGray,0.0)
            baseColor3=RGB(0.0,0.815686*scaledGray,scaledGray)
        elseif colorSet == 2
            baseColor1=RGB(0.2588*scaledGray,0.494*scaledGray,scaledGray)
            baseColor2=RGB(scaledGray,0.2588*scaledGray,0.8274*scaledGray)
            baseColor3=RGB(0.2588*scaledGray,scaledGray,0.902*scaledGray)
        elseif colorSet == 3
            baseColor1=RGB(0.89*scaledGray,0.267*scaledGray,0.353*scaledGray)
            baseColor2=RGB(0.133*scaledGray,0.373*scaledGray,0.149*scaledGray)
            baseColor3=RGB(0.635*scaledGray,0.561*scaledGray,0.812*scaledGray)
        elseif colorSet == 4
            baseColor1=RGB(0.965*scaledGray,0.471*scaledGray,0.027*scaledGray)
            baseColor2=RGB(0.0*scaledGray,0.592*scaledGray,0.584*scaledGray)
            baseColor3=RGB(0.345*scaledGray,0.604*scaledGray,0.933*scaledGray)
        elseif colorSet == 5
            baseColor1=RGB(0.4*scaledGray,0.73*scaledGray,0.98*scaledGray)
            baseColor2=RGB(0.98*scaledGray,0.47*scaledGray,0.4*scaledGray)
            baseColor3=RGB(0.6*scaledGray,0.87*scaledGray,0.4*scaledGray)
        else
            baseColor1=RGB(0.5*scaledGray,0.65*scaledGray,0.95*scaledGray)
            baseColor2=RGB(0.95*scaledGray,0.6*scaledGray,0.7*scaledGray)
            baseColor3=RGB(0.75*scaledGray,0.85*scaledGray,0.5*scaledGray)
        end
        if colorScheme == 1
            color1=baseColor3
            color2=baseColor1
            color3=baseColor2
        elseif colorScheme == 2
            color1=baseColor2
            color2=baseColor3
            color3=baseColor1
        elseif colorScheme == 3
            color1=baseColor3
            color2=baseColor2
            color3=baseColor1
        elseif colorScheme == 4
            color1=baseColor2
            color2=baseColor1
            color3=baseColor3
        elseif colorScheme == 5
            color1=baseColor1
            color2=baseColor3
            color3=baseColor2
        else
            color1=baseColor1
            color2=baseColor2
            color3=baseColor3
        end
        for jj in 0:colorRepetitions-1
            colors[jj*6*colorstepsOneColor+ii]=color2
            colors[(jj*6+2)*colorstepsOneColor-(ii-1)]=color2
            colors[(jj*6+2)*colorstepsOneColor+ii]=color1
            colors[(jj*6+4)*colorstepsOneColor-(ii-1)]=color1
            colors[(jj*6+4)*colorstepsOneColor+ii]=color3
            colors[(jj*6+6)*colorstepsOneColor-(ii-1)]=color3
        end
    end

    result = (colors, colorsteps)
    PALETTE_CACHE[cache_key] = result
    return result
end

function myimage(q::Quaternion{T},
                 radius::T,limit::T,size::Int64;
                 turnIt::Union{Quaternion{T},Nothing}=nothing,
                 colorScheme::Int64=0,
                 colorFactor::Int64=1,
                 colorOffset::Int64=0,
                 colorRepetitions::Int64=1,
                 discrete::Bool=false,
                 additionalParameter::T=0.0,
                 additionalParameter2::T=0.0)::Matrix{RGB} where {T<:AbstractFloat}
    local image=Matrix{RGB}(UndefInitializer(),size,size)
    local step = radius*2.0/convert(Float64,size)
    local (colors,colorsteps) = initPalette(colorScheme=colorScheme,colorRepetitions=colorRepetitions)
    local black=RGB(0.0,0.0,0.0)
    local turnItLoc = turnIt === nothing ? one(q) : turnIt
    local turnItNorm=normalize(turnItLoc)
    local xpos = q.w - radius
    local colorLimit=div(colorsteps-colorOffset,colorFactor)
    local lastTime=time()
    local o = one(q)
    for i in 1:size
        local now=time()
        if now>lastTime+3.0
            println("ROW=",i)
            lastTime=now
        end
        local ypos = q.x - radius
        for j in 1:size
            local n=1
            local pt = Quaternion(xpos,ypos,q.y,q.z)
            local c=(pt - q)*turnItNorm + q
            local v1=zero(c)
            local v2=zero(c)
            while true
                local currentNorm=norm(v1+v2)
                if currentNorm>=limit
                    if discrete
                      image[i,j] = colors[colorOffset+n*colorFactor]
                    else
                        local n1 = (n - 1) * sqrt(n - 1)
                        local value=1+convert(Int64,trunc((((1 + n1) * limit * (colorLimit-1))/(currentNorm+n1*limit))))
                        image[i,j] = colors[colorOffset+value*colorFactor]
                    end
                    break
                end
                if n>colorLimit-1
                    image[i,j] = black
                    break
                end
                n += 1
                vtemp = v1
                v1 = (abs(mySum(v2))>2.0 ? 0.7 * v1 * v1 : 0.03 * myAbs(v2) * v2 * v2) + c
                v2 = (myFunc(vtemp)<-1.0 ? vtemp -0.5 * v2 : 3.5 * vtemp * v2) + c
            end
            ypos += step
        end
        xpos += step
    end
    return image
end

function mydraw(fn::String,
                q::Quaternion{T},
                radius::T,limit::T,size::Int64;
                turnIt::Union{Quaternion{T},Nothing}=nothing,
                colorScheme::Int64=0,
                colorFactor::Int64=1,
                colorOffset::Int64=0,
                colorRepetitions::Int64=1,
                discrete::Bool=false,
                additionalParameter::T=0.0,
                additionalParameter2::T=0.0) where {T<:AbstractFloat}
    local image=myimage(q,radius,limit,size,
                  turnIt=turnIt,
                  colorScheme=colorScheme,
                  colorFactor=colorFactor,
                  colorOffset=colorOffset,
                  colorRepetitions=colorRepetitions,
                  discrete=discrete,
                  additionalParameter=additionalParameter,
                  additionalParameter2=additionalParameter2)
    save(fn,image)
end

function approach(x::Float64)::Float64
    return (1-exp(-8*x))/(1-exp(-8))
end

function myvideosequence()
    Random.seed!(8273262)
    local sequenceCount=1500
    local sequenceCountPhase1=160
    local radius=0.08
    local center=Quaternion(-1.4301369627,-0.00196998,0.0,0.0)
    #local centerDelta=((-3.7893,-6.9215,0.0,0.0)-center)*(1.0/sequenceCount)
    local angleStart=Quaternion(1.0,0.3,-0.7,0.5)
    local angleTarget=Quaternion(1.0,0.2,0.3,-0.5)
    #local angleFactor=normalize((66.0,rand(Float64)-0.3,0.5*(rand(Float64)-0.7),0.4*(rand(Float64)-0.4)))
    #local angleFactor

    local radiusFactor=(0.0000000002/radius)^(1.0/(sequenceCount-sequenceCountPhase1))
    #local y1=3.4
    #local yend=13.0
    #local z1=-0.5
    #local zend=-1.0
    # a+b=z1, a+700.0*b=z700,
    #local b=(yend-y1)/convert(Int64,sequenceCount-1)
    #local a=y1-b
    #local b2=(zend-z1)/convert(Int64,sequenceCount-1)
    #local a2=z1-b2
    
    for iii in 1:sequenceCount
        local fn="xx_$(iii).png"
        #if iii % 250 == 1
        #    angleFactor=normalize((66.0,rand(Float64)-0.3,0.5*(rand(Float64)-0.7),0.4*(rand(Float64)-0.4)))
        #end

        #local additionalParameter=convert(Float64,iii)
        #local vadd=a+b*additionalParameter
        #local vadd2=a2+b2*additionalParameter

        local angle = angleStart + (angleTarget-angleStart)*approach(iii/sequenceCount)

        println(iii," ",radius)

        mydraw(fn,center, radius, 1000.0, 1620,colorScheme=24,
               colorFactor=1,colorOffset=70,colorRepetitions=1,
               discrete=false,
             turnIt=angle,
                   additionalParameter=0.0,additionalParameter2=0.0)
        if iii % 151 == 0
            print("Sleep 30")
            sleep(30)
        end
        
        #angle = angle*angleFactor
        if iii > sequenceCountPhase1
            radius *= radiusFactor
        end
        #center += centerDelta
    end

    #  ffmpeg -i xx_%d.png -c:v libx264 -b:v 30000k -pass 1 -vf scale=720:720 -b:a 128k output.mp4
    #  ffmpeg -i xx_%d.png -c:v libx264 -b:v 30000k -pass 2 -vf scale=720:720 -b:a 128k output.mp4

    #  ffmpeg -i xx_%d.png -c:v libx264 -b:v 30000k -pass 1 -vf scale=1080:1080 -b:a 128k output.mp4
    #  ffmpeg -i xx_%d.png -c:v libx264 -b:v 30000k -pass 2 -vf scale=1080:1080 -b:a 128k output.mp4

    #  ffmpeg -i xx_%d.png -c:v libvpx-vp9 -b:v 30000k -pass 1 -vf scale=720:720 -c:a libopus -b:a 128k output.webm
    #  ffmpeg -i xx_%d.png -c:v libvpx-vp9 -b:v 30000k -pass 2 -vf scale=720:720 -c:a libopus -b:a 128k output.webm

end
