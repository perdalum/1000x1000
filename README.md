 >: ./det-matrix.wls matrix-1000.dat 
Reading matrix from matrix-1000.dat ...
Matrix size: 1000 x 1000
determinant = 4.356473694512643e745
time (s)    = 0.012715
 
 >: ./det-matrix-big.jl matrix-1000.dat 
Reading matrix from matrix-1000.dat ...
Matrix size: 1000 x 1000

Sign(det)   = 1.0
log|det|    = 1716.8975572250195
time (s)    = 0.10451102256774902

approx
determinant = 4.356473694513937e+745

 >: ./det-matrix-big.py matrix-1000.dat
Reading matrix from matrix-1000.dat ...
Matrix size: 1000 x 1000

Sign(det)   = 1.0
log|det|    = 1716.8975572250201
time (s)    = 0.012414932250976562

approx
determinant =  4.356473694516749e+745



needed to make an ascii-barchart plotter 😃

Time in microseconds

Python wins when N=400 
   >: ./det-all-time.sh matrix-400.dat|awk '{ printf "%s %.0f\n", $1, $2 * 1000000 }'               
wsl 3545
julia 96684
python 2517

Mathematica wins when N=1000
 >: ./det-all-time.sh matrix-1000.dat|awk '{ printf "%s %.0f\n", $1, $2 * 1000000 }'
wsl 9359
julia 99538
python 12097
  
 >: ./det-all-time.sh matrix-2000.dat|awk '{ printf "%s %.0f\n", $1, $2 * 1000000 }'
wsl 59247
julia 139426
python 53119

 >: ./det-all-time.sh matrix-4000.dat|awk '{ printf "%s %.0f\n", $1, $2 * 1000000 }'
wsl 347414
julia 411583
python 308063
 > 
>  >: ./det-all-time.sh matrix-10000.dat|awk '{ printf "%s %.0f\n", $1, $2 * 1000000 }'
wsl 4671693
julia 4209705
python 3605816

 >: ./det-all-time.sh matrix-400.dat|awk '{ printf "%s %.0f\n", $1, $2 * 100000 }'|ascii-barchart 
wsl    #
julia  ##################################################
python ##


Here are the differences on the femto scale between the calculations by the three implementations. Mathematica and Julia are a bit closer than Python/NumPy. Why?

 >: ./det-all.sh matrix-1000.dat|./calc-diff.sh|ascii-barchart
wsl    ####################
julia  #############################
python ##################################################
 

## Today I learned

- bc FTW
- zsh while loop
 
## Future Work

- Go spelunking in the source code of Julia and NumPy to learn about how this is done.
- Try do see how deep one could get in Mathematica