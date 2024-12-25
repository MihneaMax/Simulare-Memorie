.data
    input_file: .asciz "input.txt"
    output_file: .asciz "output.txt"
    memorie: .space 8000
    operatie: .space 4
    n: .space 4
    buf: .space 256
    formatin: .asciz "%ld"
    formatout: .asciz "%ld\n"
    i: .space 4
    numarfisiere: .space 4
    inumarfisiere: .space 4
    descriptorfisier: .space 4
    dimensiune: .space 4
    formatafisare: .asciz "%d: (%d, %d)\n" 
    formatoutspace: .asciz "%ld "
    formatget: .asciz "(%d, %d)\n"
    ENDL: .asciz " "
    indiceincepuit: .space 4
    indicefinal: .space 4
    idefor: .space 4
    opt: .long 8
    douazeci: .long 20
    omiedouaspatru: .long 1024
    formatendl: .asciz "%ld"
    pozitie_curenta: .long 0
    contor_cautare: .space 4
    contor_de_zero: .space 4
    contor_spatiu: .space 4
    contor_inceput_zerouri: .space 4
    nrblocks: .space 4
    zero: .long 0
    ultim: .space 4
    fisiercautat: .space 4
    flag: .space 4
    primulindex: .space 4
    ultimulindex: .space 4
    indicecurent: .space 4
    saijnoua: .long 69

.text
.global main
main:
    pushl $n
    pushl $formatin
    call scanf
    popl %ebx
    popl %ebx

   # deci acum am citit n-ul, cate operatii efectuam
    #creeare vector memorie simulata

    lea memorie, %edi
    movl $0,%ecx

  #punem 0 in tot vectorul
  #  et_for_zerouri:
  #      movl omiedouaspatru, %eax
  #      cmp %ecx, %eax
  #      je et_finish_for_zerouri
  #      movl $0, %ebx
  #      movl %ebx,(%edi,%ecx,4)
  #      incl %ecx
  #      jmp et_for_zerouri
  #
  #  et_finish_for_zerouri:
  #nu mai trebuie deoarece memoria e ok dupa cateva modificari, insa il las aici in caz de :)


  
    xor %ecx, %ecx
    movl $0,i

    et_for_main: 
        movl i,%eax
        cmp %eax,n
        je et_exit 

        pushl $operatie
        pushl $formatin
        call scanf
        popl %ebx
        popl %ebx
    
        #citim operatia pe care vrem sa o facem 
        
        movl $1,%eax
        cmp operatie,%eax
        je et_addaug

        movl $2,%eax
        cmp operatie,%eax
        je et_get

        movl $3,%eax
        cmp operatie,%eax
        je et_delete

        movl $4,%eax
        cmp operatie,%eax
        je et_defrag

        continue:
        incl i
        jmp et_for_main

et_addaug:

    pushl $numarfisiere
    pushl $formatin
    call scanf
    popl %ebx
    popl %ebx


    #stim care fisiere vrem sa adaugam


    movl $0, inumarfisiere

    et_for_adaugat:
        movl inumarfisiere,%eax
        cmp %eax,numarfisiere
        je et_finish_for_adaugat


        #daca nu am adaugat toate fisierele
        #citim un fisier nou si il adaugam in vector
        
        pushl $descriptorfisier
        pushl $formatin
        call scanf
        popl %ebx
        popl %ebx

        pushl $dimensiune
        pushl $formatin
        call scanf
        popl %ebx
        popl %ebx
        

        #daca dimensiunea este mai mica  sau egala decat 8, o facem automat 9 pentru a ocupa minim 2 blocuri(cerinta)

        movl dimensiune, %eax
        cmpl $8, %eax
        jle setare_dimensiune
        jmp sfarsit_if
        setare_dimensiune:
            movl $9,dimensiune

        sfarsit_if:
        #salvam indicele de inceput:
        movl pozitie_curenta,%eax
        movl %eax,indiceincepuit

        #un for de la 1 la (dimensiunea-1)/8+1    

        #eax=[(dimensiune-1)/8+1]
        movl dimensiune,%eax
        decl %eax
        movl $0,%edx
        divl opt
        incl %eax
        #eax=[(dimensiune-1)/8+1]


        #in momentul asta avem in %eax nuamrul de blocuri necesar pentru a pune descriptorul.
        movl %eax,nrblocks
        movl %eax,dimensiune
        #acum avem in nrblocks numarul de nlocuri necesare



        movl $0,contor_de_zero
        movl $0,contor_cautare
        movl $0, contor_spatiu
        movl $-1, contor_inceput_zerouri

        et_cautare_loc:
            movl contor_cautare,%ebx
            cmp %ebx,omiedouaspatru
            je et_nu_este_spatiu

            movl contor_cautare,%ebx
            movl (%edi,%ebx,4),%eax
            
            cmp %eax,zero
            jne et_resetare_contor_zerouri
            jmp et_count_spatii





            et_count_spatii:
                incl contor_de_zero
                mov dimensiune,%eax
                cmp %eax,contor_de_zero # daca sunt mai multe spatii goale decat avem nevoie,se duce direct sa ii retina inceputul
                jge retineinceput
                jmp elsulmare

            et_resetare_contor_zerouri:
                mov dimensiune,%eax
                cmp %eax,contor_de_zero
                jge retineinceput
                jmp else

                retineinceput:
                movl contor_cautare,%eax
                sub contor_de_zero,%eax
                decl %eax
                movl %eax,contor_inceput_zerouri
                jmp et_concluize_spatii
                else:
                    movl $0,contor_de_zero
            
                elsulmare:
                incl contor_cautare
                jmp et_cautare_loc

            et_concluize_spatii:
                #avem spatiile si incepul lor deci putem baga de acolo.
                #trebuie sa adaugam de 'dimensiune' ori descriptorul, incepand cu contor_inceput_zerouri inclusiv
                movl $0,idefor
                addl $2,contor_inceput_zerouri
                movl contor_inceput_zerouri,%ecx
                et_for_pt_fiecare_fisier:
                    movl nrblocks,%eax
                    cmp idefor,%eax
                    je et_finish_for_pt_fiecare_fisier
                    movl descriptorfisier, %ebx
                    movl %ebx,(%edi,%ecx,4)
                    movl %ecx,ultim
                    incl %ecx
                    incl idefor
                    jmp et_for_pt_fiecare_fisier

                et_finish_for_pt_fiecare_fisier:
                    movl ultim, %eax
                    pushl %eax
                    movl contor_inceput_zerouri, %eax
                    pushl %eax
                    movl descriptorfisier, %eax
                    pushl %eax
                    pushl $formatafisare
                    call printf
                    popl %ebx
                    popl %ebx
                    popl %ebx

                    
                    incl inumarfisiere
                    jmp et_for_adaugat
    et_nu_este_spatiu:
        #afisam (0,0)
        movl zero, %eax
        pushl %eax
        movl zero, %eax
        pushl %eax
        movl descriptorfisier, %eax
        pushl %eax
        pushl $formatafisare
        call printf
        popl %ebx
        popl %ebx
        popl %ebx        
        incl inumarfisiere
        jmp et_for_adaugat



    et_finish_for_adaugat:

    jmp continue
et_get:
    #operatia de get consta in cautarea primei aparitii ,pana unde un flag o sa fie 0, daca ajunge la ecx=1024, atunci va afisa 00
    #apoi de la prima aparitie unde flagul se activeaza si counterul de aparitii devine 1, incepe o noua eticheta
    #de cautare, care se opreste la primul element diferit de cel citit

    pushl $fisiercautat
    pushl $formatin
    call scanf
    popl %ebx
    popl %ebx


    #avem in fisiercautat descriptorul pe care il dorim.


    xorl %ecx, %ecx
    movl $0,flag
    movl $0, primulindex

    et_loopcautareprimul:
        cmp %ecx,omiedouaspatru
        je et_terminareloop
        movl (%edi,%ecx,4),%ebx
        cmp %ebx, fisiercautat
        je et_gasit
        jmp continualoop
        et_gasit:
            movl %ecx, primulindex
            movl omiedouaspatru,%ecx
            movl $1, %eax
            movl %eax,flag
            ## daca a fost gasit primul numar care corespunde fisierului dorit, va iesi automat din for, cu indicele ecx pastrat
            ##in "primul index"
            jmp et_loopcautareprimul
        continualoop:
        incl %ecx
        jmp et_loopcautareprimul

    et_terminareloop:
        #daca nu a fost gasit si flagul e tot 0
       #sau daca a fost gasit si flagul este unu, inseamna ca ul elem este in descriptor
        movl flag,%eax
        movl $1,%ebx
        cmp %eax,%ebx
        je et_cautareultim
        #daca nu a fost gasit, afisam (0,0) si ne intoarcem in main
        movl zero, %eax
        pushl %eax
        movl zero, %eax
        pushl %eax
        pushl $formatget
        call printf
        popl %ebx
        popl %ebx
        jmp continue # sa reintre in et_for_main
        et_cautareultim:
            #daca exista un prim numar, pornim de la indicele sau si mergem pana la ultima sa aparitie


            movl primulindex, %ecx
            movl %ecx, ultimulindex
            et_loopcautareultim:
                movl (%edi,%ecx,4),%eax
                cmp %eax,fisiercautat
                jne et_gata
                incl %ecx
                jmp et_loopcautareultim
                et_gata:
                    decl %ecx
                    movl %ecx,ultimulindex
                    jmp et_afisareget 
        et_afisareget:
            ##afisare
            movl ultimulindex, %eax
            pushl %eax
            movl primulindex, %eax
            pushl %eax
            pushl $formatget
            call printf
            popl %ebx
            popl %ebx
            jmp continue ##inapoi in main









et_delete:

    pushl $fisiercautat
    pushl $formatin
    call scanf
    popl %ebx
    popl %ebx


    #avem in fisiercautat descriptorul pe care il dorim.
    


    xorl %ecx, %ecx
    movl $0,indicecurent
    
    et_loopdelete:
        cmp %ecx,omiedouaspatru
        je et_afisareavectorului
        movl (%edi,%ecx,4),%ebx
        cmp %ebx,fisiercautat
        jne skip
        movl $0,(%edi,%ecx,4)

        skip:
        incl %ecx
        jmp et_loopdelete

et_defrag:
    movl $0,indicecurent #asta e index din c++
    xorl %ecx,%ecx     # asta e i ul din c++

    et_forlooop:
    cmp %ecx,omiedouaspatru
    je et_afisareavectorului
    movl (%edi,%ecx,4),%ebx
    cmp %ebx,zero
    je skipforunu
    movl indicecurent,%eax
    movl %ebx,(%edi,%eax,4)

    cmp %eax,%ecx
    je skipfordoi
    movl $0,(%edi,%ecx,4)

    skipfordoi:
    incl indicecurent
    incl %eax

    skipforunu:
    incl %ecx
    jmp et_forlooop


et_afisareavectorului:
    movl $0, %ecx
    movl $0, indicecurent

    et_whilezero:
        movl indicecurent, %ecx
        cmp %ecx, omiedouaspatru
        je continue

        movl (%edi, %ecx, 4), %ebx
        cmp %ebx, zero
        jne gasitnenul

        incl %ecx
        movl %ecx, indicecurent
        jmp et_whilezero

    gasitnenul:
        movl %ecx, indiceincepuit
        movl %ebx, descriptorfisier

    et_cauta_loop:
        cmp %ecx, omiedouaspatru
        je afis_concluzie

        movl (%edi, %ecx, 4), %ebx
        cmp descriptorfisier, %ebx
        jne finalizeaza_afisare

        movl %ecx, indicefinal
        incl %ecx
        movl %ecx, indicecurent
        jmp et_cauta_loop

    afis_concluzie:
        movl indicefinal, %eax
        pushl %eax
        movl indiceincepuit, %eax
        pushl %eax
        movl descriptorfisier, %eax
        pushl %eax
        pushl $formatafisare
        call printf
        addl $16, %esp               # Curăță stiva
        jmp et_whilezero             # Continuă căutarea

    finalizeaza_afisare:
        # Afișează datele și reia căutarea de la următorul zero
        movl indicefinal, %eax
        pushl %eax
        movl indiceincepuit, %eax
        pushl %eax
        movl descriptorfisier, %eax
        pushl %eax
        pushl $formatafisare
        call printf
        addl $16, %esp               # Curăță stiva
        jmp et_whilezero             # Continuă căutarea
et_exit:
 

   # #afisam un endl pentru vizibilitate in consola
   # pushl $0x0A
   # pushl $formatendl
   # call printf 
   # popl %ebx
   # popl %ebx
   # # # # # # # # # #

    pushl $0
    call fflush
    popl %eax

    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80