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
import Random
using Images
using ColorTypes
using Match

function setindex((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat},
                   v::AbstractFloat, index::Int64
                   )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    index==1 && return (v,x2,x3,x4)
    index==2 && return (x1,v,x3,x4)
    index==3 && return (x1,x2,v,x4)
    return (x1,x2,x3,v)
end
function zero(a::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
              )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return (0.0,0.0,0.0,0.0)
end
function iszero((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
              )::Bool
    return x1==0.0 && x2==0.0 && x3==0.0 && x4==0.0
end

function one((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
             )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return (1.0,0.0,0.0,0.0)
end

function +((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat},
           (y1,y2,y3,y4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
           )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return (x1+y1,x2+y2,x3+y3,x4+y4)
end

function -((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat},
           (y1,y2,y3,y4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
           )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return (x1-y1,x2-y2,x3-y3, x4-y4)
end
function -((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
           )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return (-x1,-x2,-x3,-x4)
end

function *((x1,x2,x3, x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}, y::AbstractFloat
           )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return (x1*y,x2*y,x3*y,x4*y)
end
function *(y::AbstractFloat, (x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
           )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return (x1*y,x2*y,x3*y,x4*y)
end

# \cdot tab
function ⋅((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat},
          (y1,y2,y3,y4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat})::AbstractFloat
    return x1*y1+x2*y2+x3*y3+x4*y4
end

function norm(x::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat})::AbstractFloat
    return sqrt(x ⋅ x)
end
function normalize(a::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
                   )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    local n=norm(a)
    if n==0.0
        return a
    end
    return (1.0/n)*a
end

function conj((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
             )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return (x1,-x2,-x3,-x4)
end

function inv((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
             )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return (1.0/(x1*x1+x2*x2+x3*x3+x4*x4))*(x1,-x2,-x3,-x4)
end

function isnan((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
               )::Bool
    return isnan(x1) || isnan(x2) || isnan(x3) || isnan(x4) 
end

function isinf((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
               )::Bool
    return isinf(x1) || isinf(x2) || isinf(x3) || isinf(x4) 
end

function *((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat},
           (y1,y2,y3,y4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
           )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return (x1*y1-x2*y2-x3*y3-x4*y4,
            x2*y1+x1*y2+x3*y4-x4*y3,
            x3*y1+x1*y3-x2*y4+x4*y2,
            x1*y4+x4*y1+x2*y3-x3*y2)
end

function /(a::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat},
           b::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
           )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
    return a*inv(b)
end

# wrong multiplication
function funnyMultiply((x1,x2,x3,x4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat},
           (y1,y2,y3,y4)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
           )::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}
     return (x1*y1-x2*y2-x3*y3-x4*y4,
             x2*y1+x1*y2+x3*y4+x4*y3,
             x3*y1+x1*y3+x2*y4+x4*y2,
             x1*y4+x4*y1+x2*y3+x3*y2)
end

function initPalette(;colorScheme::Int64=0,
                     colorRepetitions::Int64=1)::Tuple{Vector{RGB},Int64}
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
        else
            baseColor1=RGB(0.2588*scaledGray,0.494*scaledGray,scaledGray)
            baseColor2=RGB(scaledGray,0.2588*scaledGray,0.8274*scaledGray)
            baseColor3=RGB(0.2588*scaledGray,scaledGray,0.902*scaledGray)
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
    return (colors,colorsteps)
end

function myimage((x,y,z,u)::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat},
                 radius::AbstractFloat,limit::AbstractFloat,size::Int64;
                 turnIt::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}=(1.0,0.0,0.0,0.0),
                 colorScheme::Int64=0,
                 colorFactor::Int64=1,
                 colorOffset::Int64=0,
                 colorRepetitions::Int64=1,
                 discrete::Bool=false,
                 additionalParameter::AbstractFloat=0.0,
                 additionalParameter2::AbstractFloat=0.0)::Matrix{RGB}
    # println("PREC=",precision(x))
    local image=Matrix{RGB}(UndefInitializer(),size,size)
    local step = radius*2.0/convert(Float64,size)
    local (colors,colorsteps) = initPalette(colorScheme=colorScheme,colorRepetitions=colorRepetitions)
    local black=RGB(0.0,0.0,0.0)
    local turnItNorm=normalize(turnIt)
    local xpos = x-radius
    local colorLimit=div(colorsteps-colorOffset,colorFactor)
    local o = one(turnIt)
    local lastTime=time()
    for i in 1:size
        local now=time()
        if now>lastTime+3.0
            println("ROW=",i)
            lastTime=now
        end
        local ypos = y-radius
        for j in 1:size
            local n=1
            local c=((xpos,ypos,z,u)-(x,y,z,u))*turnItNorm+(x,y,z,u)
            local v1=zero(c)
            local v2=zero(c)
            local v3=zero(c)
            while true
                local currentNorm=norm(v1+v2+v3)
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
                v1 = 0.0005 * v1 * v1 * v2 - 0.0005 * v1 * v1 * v1 * v1 + 2.3 * v2 + c
                v2 = 0.0002 * v2 * v2 - additionalParameter * v3 + c
                v3 = -0.25 * v3 * v3 * v2 - additionalParameter2 * vtemp + c
            end
            ypos += step
        end
        xpos += step
    end
    return image
end

function mydraw(fn::String,
                a::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat},
                radius::AbstractFloat,limit::AbstractFloat,size::Int64;
                turnIt::Tuple{AbstractFloat, AbstractFloat, AbstractFloat, AbstractFloat}=(1.0,0.0,0.0,0.0),
                colorScheme::Int64=0,
                colorFactor::Int64=1,
                colorOffset::Int64=0,
                colorRepetitions::Int64=1,
                discrete::Bool=false,
                additionalParameter::AbstractFloat=0.0,
                additionalParameter2::AbstractFloat=0.0,
                sequenceCountParameter::Int64=2)
    local image=myimage(a,radius,limit,size,
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

function myvideosequence()
    Random.seed!(8273262)
    local sequenceCount=1000
    #local sequenceCountPhase1=150
    local radius=13.0
    local center=(-2.97448464,1.77740984, 0.0, 0.0)
    #local centerDelta = ((0.0,0.0,0.0,0.0)-center)*(1.0/sequenceCountPhase1)
    local angle=(1.0,0.0,0.0,0.0)
    local angleFactor=normalize((66.0,1.0,0.0,0.0))
    local radiusFactor=(0.00000001/radius)^(1.0/sequenceCount)
    for iii in 1:sequenceCount
        local fn="xx_$(iii).png"
        #if iii % 100 == 1
        #    angleFactor=normalize((66.0,rand(Float64)-0.3,6.0*(rand(Float64)-0.7),4.0*(rand(Float64)-0.4)))
        #end

        #local additionalParameter=convert(Float64,iii)
        #local y1=-0.3
        #local yend=0.1
        #local z1=-0.5
        #local zend=-1.0
        # a+b=z1, a+700.0*b=z700,
        #local b=(yend-y1)/convert(Int64,sequenceCount-1)
        #local a=y1-b
        #local vadd=a+b*additionalParameter
        #b=(zend-z1)/convert(Int64,sequenceCount-1)
        #a=z1-b
        #local vadd2=a+b*additionalParameter

        println(iii," ",radius, " ", center)

        mydraw(fn,center, radius, 1000.0, 1620,colorScheme=22,
               colorFactor=1,colorOffset=70,colorRepetitions=1,
               discrete=false,
               turnIt=angle,
               additionalParameter=0.0,additionalParameter2=0.0)
        radius *= radiusFactor
        angle = angle*angleFactor
        #center += centerDelta
    end

    #  ffmpeg -i xx_%d.png -c:v libx264 -b:v 30000k -pass 1 -vf scale=720:720 -b:a 128k output.mp4
    #  ffmpeg -i xx_%d.png -c:v libx264 -b:v 30000k -pass 2 -vf scale=720:720 -b:a 128k output.mp4

    #  ffmpeg -i xx_%d.png -c:v libx264 -b:v 30000k -pass 1 -vf scale=1080:1080 -b:a 128k output.mp4
    #  ffmpeg -i xx_%d.png -c:v libx264 -b:v 30000k -pass 2 -vf scale=1080:1080 -b:a 128k output.mp4

    #  ffmpeg -i xx_%d.png -c:v libvpx-vp9 -b:v 30000k -pass 1 -vf scale=720:720 -c:a libopus -b:a 128k output.webm
    #  ffmpeg -i xx_%d.png -c:v libvpx-vp9 -b:v 30000k -pass 2 -vf scale=720:720 -c:a libopus -b:a 128k output.webm

end
