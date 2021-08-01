import Base.+
import Base.-
import Base.*
using Images
using ColorTypes

function +((x1,x2,x3)::Tuple{Float64, Float64, Float64}, (y1,y2,y3)::Tuple{Float64, Float64, Float64})
    return (x1+y1,x2+y2,x3+y3)
end

function -((x1,x2,x3)::Tuple{Float64, Float64, Float64}, (y1,y2,y3)::Tuple{Float64, Float64, Float64})
    return (x1-y1,x2-y2,x3-y3)
end

function norm((x1,x2,x3)::Tuple{Float64, Float64, Float64})
    return sqrt(x1*x1+x2*x2+x3*x3)
end

function *((x1,x2,x3)::Tuple{Float64, Float64, Float64}, (y1,y2,y3)::Tuple{Float64, Float64, Float64})
    return (x2*y3+x3*y2-x3*y3,x1*y3+x3*y1-x1*y1,x1*y2+x2*y1-x2*y2)
end

# i*j == k, j*k == i, k*i == j, i*i==-j, j*j==-k, k*k==-i
#(i*x1+j*x2+k*x3)*(i*y1+j*y2+k*y3)
# == i*i*x1*y1+i*j*(x1*y2+x2*y1)+i*k*(x1*y3+x3*y1)+j*j*x2*y2+j*k*(x2*y3+x3*y2)+k*k*x3*y3
# == i*i*x1*y1+k*(x1*y2+x2*y1)+j*(x1*y3+x3*y1)+j*j*x2*y2+i*(x2*y3+x3*y2)+k*k*x3*y3
# == -j*x1*y1+k*(x1*y2+x2*y1)+j*(x1*y3+x3*y1)-k*x2*y2+i*(x2*y3+x3*y2)-i*x3*y3
# == i*(x2*y3+x3*y2-x3*y3)+j*(x1*y3+x3*y1-x1*y1)+k*(x1*y2+x2*y1-x2*y2)


function myimage(x::Float64,y::Float64,z::Float64,radius::Float64,size::Int64)
    image=Matrix{RGB}(UndefInitializer(),size,size)
    step = radius*2.0/convert(Float64,size)
    gray = 1.0/256.0
    xpos = x-radius
    for i in 1:size
        ypos = y-radius
        for j in 1:size
            n=0
            v=(xpos,ypos,z)
            while true
                if norm(v)>=1000.0
                    color=gray*convert(Float64,n)
                    image[i,j] = RGB(color,color,color)
                    break
                end
                if n>255
                    image[i,j] = RGB(0.0,0.0,0.0)
                    break
                end
                n += 1
                v = v * v
            end
            ypos += step
        end
        xpos += step
    end
    return image
end

function mydraw(fn::String,x::Float64,y::Float64,z::Float64,radius::Float64,size::Int64)
    image=myimage(x,y,z,radius,size)
    save(fn,image)
end
