def rotate(l, x):
  return l[-x:] + l[:-x]

#ls = [0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7 ]
ls = [7,7,7,7,0,1,2,3,4,5,6,7,7,7,7,7 ]

#s =  [1,1,1, 2,2,2, 3,3,3,3, 2,2,2, 1,1,1]

# best so far
s =  [1,1,1, 1,2,2, 3,4,4,3, 2,2,1, 1,1,1]


if len(s) != 16:
    print (f'len(s) should be 16, but is {len(s)}')
elif len(ls) != 16:
    print (f'len(ls) should be 16, but is {len(ls)}')

elif sum(s) != 30 :
    print (f'sum(s) should be 30, but is {sum(s)}')
else: 

    for i in range(0,16) :
        print (f'patterns{i}:')
        print ('.fill 1,f7 ')
        for j,l in enumerate(rotate(ls, -i)) :
                
                print(f'  .fill {s[j]}, f{l}')

        print ('.fill 1,f7 ')