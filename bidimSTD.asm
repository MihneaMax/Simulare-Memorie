.data
    memorie: .space 8421408  # Matrice 1024x1024, fiecare element de 4 bytes
    memorietemp: .space 8421408
    operatie: .space 4
    n: .space 4
    buf: .space 256
    formatin: .asciz "%ld"
    testare: .asciz "\n testare \n"
    formatAddOut: .asciz "%ld: ((%ld, %ld), (%ld, %ld))\n"
    formatGetOut: .asciz "((%ld, %ld), (%ld, %ld))\n"
    i: .long 0
    numarfisiere: .space 4
    descriptorfisier: .space 4
    dimensiune: .space 4
    opt: .long 8
    omiedouaspatru: .long 1024
    zero: .long 0
    nrblocks: .space 4
    indicelinie: .long 0
    coloanafinal: .long 0
    coloanastart: .long 0
    numarblocks: .long 0
    iAdd: .long 0
    indexColoana: .long 0
    indexLinie: .long 0
    formatPrintf: .asciz "%ld "
    newLine: .asciz "\n"
    counter_zerouri: .long 0
    indicelinie_temp: .long 0
    indicecolana_temp: .long 0
    numarlocurinecesare: .long 0
    indicecolanafinala_temp: .long 0
    flagpacalit: .long 0
    counterElementeTotale: .long 0
    counterElementePanaAcum: .long 0
.text
    #;un element din matrice se va accesa prin formula
   # ; %edi + (indicelinie * 1024 + indice coloana)* 4, 4 venind de la longuri.
.global main
main:
    
    pushl $n
    pushl $formatin
    call scanf
    popl %ebx
    popl %ebx

    lea memorie, %edi
    lea memorietemp, %esp

    movl $0, %eax
    movl $0, i

    main_loop:
        movl i, %eax
        cmpl n, %eax
        je et_exit

        pushl $operatie
        pushl $formatin
        call scanf
        popl %ebx
        popl %ebx

        movl operatie, %eax
        
        cmpl $1, %eax
        je et_add

        cmpl $2, %eax
        je et_get

        cmpl $3, %eax
        je et_delete

        cmpl $4, %eax
        je et_defragmentare


        continue:
            incl i
            jmp main_loop

et_add:

    pushl $numarfisiere
    pushl $formatin
    call scanf
    popl %ebx
    popl %ebx
    movl $0, iAdd

    et_loop_adaugare:
        movl iAdd, %eax
        cmp numarfisiere, %eax
        je continue  #; daca s-au term de adaugat, continuam in main

        incl counterElementeTotale

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


        movl dimensiune, %eax
        cmpl $8, %eax
        jle setare_dimensiune
        jmp sfarsit_if
        setare_dimensiune:
            movl $9,dimensiune
        sfarsit_if:
        #;%eax=[(dimensiune-1)/8+1]
        movl dimensiune,%eax
        decl %eax
        movl $0,%edx
        divl opt
        incl %eax
        #;%eax=[(dimensiune-1)/8+1]

        movl %eax,nrblocks
        movl %eax,dimensiune

        cmp omiedouaspatru, %eax
        jg et_nu_este_spatiu
        #; stim sigur ca nu va incapea pe un singur rand deci nu poate fi bagat in memorie

        #;trebuie sa cautam o linie cu "nrblocks" de  0-uri avalibale ca saa punem descriptorul.






        ###############
        ###############
        ###############         ;ESTE CORECT TOTUL PANA AICI. AVEM IN NRBLOCKS NUMARUL DE ZEROURI DE CARE AVEM NEV
        ###############
        ###############

        movl $0,indicelinie
    
        et_loop_linie:
            movl indicelinie,%eax
            cmp %eax,omiedouaspatru
            je et_nu_este_spatiu




            #;daca am ajuns pe o linie noua, inseamna ca nu am gasit inca nimic deci le putem reseta pentru noi .

            movl $0,coloanastart
            movl $0,coloanafinal

            movl indicelinie, %eax
            imull omiedouaspatru, %eax
            lea (%edi, %eax, 4), %esi     #;%esi=adresa inceputului liniei deci matrix[indiceline][0]


            movl $0, %ecx                    #; indicele curent al coloanei
            movl $0, counter_zerouri
            movl $0, indexColoana

            et_for_pe_coloane:
                movl indexColoana,%ecx
                cmp %ecx,omiedouaspatru
                je et_newline

                movl indexColoana, %ecx
                movl (%esi,%ecx,4), %ebx

                cmp $0,%ebx
                jne reset_counter

                incl counter_zerouri

                movl nrblocks,%ebx
                cmp %ebx,counter_zerouri
                jne continua_cautare_zerouri
                #;deci am ajuns la ultima pozitiept asezare
                movl indexColoana,%eax
                movl %eax,coloanafinal
                subl nrblocks,%eax
                addl $1,%eax
                movl %eax,coloanastart
                jmp et_poate_fi_adaugat

                continua_cautare_zerouri:
                    incl indexColoana
                    jmp et_for_pe_coloane

                reset_counter:
                    movl $0,counter_zerouri
                    incl indexColoana
                    jmp et_for_pe_coloane

                et_newline:
                    incl indicelinie
                    jmp et_loop_linie


    et_poate_fi_adaugat:
        #;avem coloana start, indicelinie si coloanafinal
        #;ordinea este 1) descriptor 2) indicelinie 3) cooloana start 4) indicelinie 5) coloanafinal
        movl coloanafinal, %eax
        pushl %eax

        movl indicelinie,%eax
        pushl %eax

        movl coloanastart, %eax
        pushl %eax

        movl indicelinie,%eax
        pushl %eax

        movl descriptorfisier,%eax
        pushl %eax

        pushl $formatAddOut
        
        call printf

        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx

        #;trebuie sa adaugam efectiv elementele in matrice.
        
        movl coloanastart,%ebx
        movl %ebx,indexColoana
        incl coloanafinal

        et_for_pe_coloane_adaugare:
                movl indexColoana,%ecx
                cmp %ecx,coloanafinal
                je gata_for_adaugare
                movl descriptorfisier,%ebx
                mov %ebx,(%esi,%ecx,4)
                incl indexColoana
                jmp et_for_pe_coloane_adaugare



        gata_for_adaugare:
            incl iAdd
            jmp et_loop_adaugare

    et_nu_este_spatiu:
        pushl $0
        pushl $0
        pushl $0
        pushl $0

        movl descriptorfisier,%eax
        pushl %eax

        pushl $formatAddOut

        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        incl iAdd
        jmp et_loop_adaugare
et_get:

    pushl $descriptorfisier
    pushl $formatin
    call scanf
    popl %ebx
    popl %ebx



    movl $0,indicelinie

    et_cautare_prima_aparitie:
        movl indicelinie,%eax
        cmp %eax,omiedouaspatru
        je nu_exista

        movl indicelinie, %eax
        imull omiedouaspatru, %eax
        lea (%edi, %eax, 4), %esi
        #; primul element

        movl $0, indexColoana
        et_for_coloane_get:
            movl indexColoana, %ecx
            cmp %ecx,omiedouaspatru
            je et_new_line_get
            movl (%esi,%ecx,4),%ebx
            cmp %ebx,descriptorfisier
            je gasit_primul
            incl indexColoana
            jmp et_for_coloane_get
        et_new_line_get:
            movl $0, indexColoana
            incl indicelinie
            jmp et_cautare_prima_aparitie

    gasit_primul:
        movl indicelinie, %ebx
        movl %ebx, indexLinie
        movl indexColoana,%ebx
        movl %ebx,coloanastart

        incl indexColoana
        et_cautare_a_doua_aparitie:
            movl indexColoana,%ecx
            movl (%esi,%ecx,4),%ebx
            cmp %ebx,descriptorfisier
            jne gasit_anterior
            movl indexColoana,%ebx
            movl %ebx,coloanafinal

            cmp %ecx,omiedouaspatru
            je lastcheck_get

            incl indexColoana
            jmp et_cautare_a_doua_aparitie


        gasit_anterior:
            decl indexColoana
            movl indexColoana,%ebx
            movl %ebx, coloanafinal
            jmp afisare_get
        lastcheck_get:
            decl %ecx
            movl (%esi,%ecx,4),%ebx
            cmp %ebx, descriptorfisier
            jne nu_exista
            movl indexColoana,%ebx
            movl %ebx,coloanafinal
            jmp afisare_get
    afisare_get:
        #;aceeasi afisare ca la add

        movl coloanafinal, %eax
        pushl %eax

        movl indexLinie,%eax
        pushl %eax

        movl coloanastart, %eax
        pushl %eax

        movl indicelinie,%eax
        pushl %eax

        pushl $formatGetOut
        
        call printf

        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        jmp continue
    nu_exista:
        pushl $0
        pushl $0
        pushl $0
        pushl $0

        pushl $formatGetOut

        call printf
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        popl %ebx
        jmp continue

et_delete:
    pushl $descriptorfisier
    pushl $formatin
    call scanf
    popl %ebx
    popl %ebx

    #; $$$$$$$$$$$$$$$$$
    

    movl $0,indicelinie

    et_loop_delete:
        movl indicelinie,%eax
        cmp %eax,omiedouaspatru
        je et_afisare_memorie

        movl indicelinie, %eax
        imull omiedouaspatru, %eax
        lea (%edi, %eax, 4), %esi

        movl $0, indexColoana
        et_for_coloane_delete:
            movl indexColoana, %ecx
            cmp %ecx,omiedouaspatru
            je et_new_line_delete
            movl (%esi,%ecx,4),%ebx
            cmp %ebx,descriptorfisier
            je et_stergere
            jmp skip_stergere
            et_stergere:
                movl $0,(%esi,%ecx,4)
                decl counterElementeTotale
            skip_stergere:
            incl indexColoana
            jmp et_for_coloane_delete
        et_new_line_delete:
            movl $0, indexColoana
            incl indicelinie
            jmp et_loop_delete
et_defragmentare:
    #; pentru defragmentare o sa folosim o matrice teporala
    #; unde vom rearanja elementele din matrice comform defragmentarii
    #; mai apoi punandu-le inapoi in matricea originala.



    #; o sa vedem daca un element incape sau nu pe linia pe care suntem in momentul dat
    #; in matricea temporala stiind ca ea are maxim 1024 de blockuri disponibile, deci 
    #; locurile goale vor fi 1024-pozitia actuala ( indicecolana_temp)


    #; aevm in %esp adresa de inceput al matricei matricetemp
    movl $0, counterElementePanaAcum
    lea memorietemp, %esp

    movl $0, indicecolana_temp
    movl $0, indicelinie_temp

    movl indicecolana_temp,%eax
    imull omiedouaspatru,%eax
    lea (%esp,%eax,4),%ebp

    movl $0, indexLinie
    movl $0, indexColoana

    et_loop_linie_defrag:
        movl indexLinie,%eax
        cmp %eax,omiedouaspatru
        je et_remediere
        imull omiedouaspatru,%eax
        lea (%edi,%eax,4), %esi  

        movl $0, indexColoana
        et_loop_cautare_prima_aparitie_defrag:
            movl indexColoana,%ecx
            cmp %ecx,omiedouaspatru
            je newLine_defrag

            movl (%esi,%ecx,4),%ebx

            cmp $0, %ebx
            jne gasit_primul_defrag
            incl indexColoana
            jmp et_loop_cautare_prima_aparitie_defrag
            #;daca nu e zero, am gasit prima aparitie a unui element
            jmp et_cautare_a_doua_aparitie_defrag
            et_revenire_dUpa_adaugare_in_temp:
            incl indexColoana
            jmp et_loop_cautare_prima_aparitie_defrag
        gasit_primul_defrag:
            movl indexColoana,%ecx
            movl %ecx,coloanastart
            movl (%esi,%ecx,4),%ebx
            movl %ebx,descriptorfisier
            incl counterElementePanaAcum

            et_cautare_a_doua_aparitie_defrag:
                movl indexColoana,%ecx
                cmp %ecx,omiedouaspatru
                je last_check_defrag_coloana
                movl (%esi,%ecx,4),%ebx
                cmp %ebx,descriptorfisier
                je continua_cautare_defrag
                #; daca nu este egal inseamna ca precedentul a fostultimul de acel fel
                decl indexColoana 
                movl indexColoana,%ebx

                movl %ebx, coloanafinal
                movl coloanafinal, %eax




                #avem in coloanastart si coloana final.
                movl coloanafinal ,%eax
                subl coloanastart, %eax
                incl %eax
                movl %eax,numarlocurinecesare   #; nr de locuri necesare in temp

                movl omiedouaspatru,%eax
                subl indicecolana_temp,%eax
                et_pacalit:
                cmp %eax,numarlocurinecesare
                jg next_line_temp
                
                #; daca a ramas aici, are destule locuri pe linia aceasta
                # consideram ca  indicecoloana_temp a ramas pe ult pus
                # deci ultimul indice al coloanei o sa fie  indeice + nr locs
                movl indicecolana_temp,%eax
                addl numarlocurinecesare,%eax
                movl %eax, indicecolanafinala_temp

                #+1 ca sa se opreasca dupa ce l- apus pe ult
                
                incl indicecolanafinala_temp



              #  incl indicecolana_temp # ca sa sara  de pe ult care era pus
                movl counterElementePanaAcum,%ebx
                cmp %ebx,counterElementeTotale
                jne et_loop_adaugare_in_temp
                decl indicecolanafinala_temp
                et_loop_adaugare_in_temp:
                    movl indicecolana_temp,%eax 
                    cmp %eax, indicecolanafinala_temp
                    je gata_adaugarea_in_temp
                    movl descriptorfisier,%ebx
                    movl %ebx,(%ebp,%eax,4)
                    incl indicecolana_temp
                    jmp et_loop_adaugare_in_temp
                
                gata_adaugarea_in_temp:
                    decl indicecolana_temp    # ca indicele sa ramana pe ult pus
                    jmp skip_next_line_temp


                next_line_temp:
                    #aici punem pe urm linie
                    incl indicelinie_temp
                    movl $0,indicecolana_temp
                    movl indicelinie_temp,%eax
                    lea (%esp,%eax,4), %ebp

                    #punem de pe 0 pana pe numarlocurinecesare-1
                    et_adaugare_linie_noua:
                        movl indicecolana_temp, %eax
                        cmp %eax,numarlocurinecesare
                        je gata_next_line
                        movl descriptorfisier,%ebx
                        movl %ebx, (%ebp,%eax,4)
                        incl indicecolana_temp
                        jmp et_adaugare_linie_noua
            gata_next_line:
                decl indicecolana_temp
            skip_next_line_temp:
                movl flagpacalit,%eax
                cmp $1,flagpacalit
                je newLine_defrag
                
                jmp et_revenire_dUpa_adaugare_in_temp

            continua_cautare_defrag:
                incl indexColoana
                jmp et_cautare_a_doua_aparitie_defrag

            last_check_defrag_coloana:

                #; daca am ajuns iaci, inseamna ca ultimul element de pe coloana respectiva era egal cu descriptorul
                #; respectiv deoarece avem minim 2 blocuri cu alecasi descriptor.
                decl indexColoana
                movl indexColoana,%ebx
                movl %ebx, coloanafinal
                

                movl coloanafinal ,%eax
                subl coloanastart, %eax
                incl %eax
                movl %eax,numarlocurinecesare   #; nr de locuri necesare in temp

                movl omiedouaspatru,%eax
                subl indicecolana_temp,%eax

                movl $1,flagpacalit
                jmp et_pacalit

                jmp newLine_defrag

        newLine_defrag:
            movl $0,indexColoana
            incl indexLinie
            jmp et_loop_linie_defrag


    et_remediere:
        movl $1023,indexLinie
        movl $1023,indexColoana
        et_loop_linie_remediere:
            movl indexLinie,%eax
            cmp $-1,%eax
            je et_mutare_inapoi
            imull omiedouaspatru,%eax
            lea (%esp,%eax,4), %ebp
            movl $1023, indexColoana
            et_loop_coloana_remediere:
                movl indexColoana,%ecx
                cmp $-1,%ecx
                je new_line_remediere
                movl (%ebp,%ecx,4),%ebx
                cmp $0,%ebx
                je skip
                movl $0,%ebx
                movl %ebx, (%ebp,%ecx,4)
                jmp et_mutare_inapoi
                skip:
                decl indexColoana
                jmp et_loop_coloana_remediere
        new_line_remediere:
            decl indexLinie
            jmp et_loop_linie_remediere
    et_mutare_inapoi:
        movl $0,indexLinie
        movl $0, indexColoana
        et_mutare_loop_linii:
            movl indexLinie, %eax
            cmp %eax,omiedouaspatru
            je et_afisare_memorie

            lea (%edi,%eax,4),%esi
            lea (%esp,%eax,4),%ebp
            
            movl $0, indexColoana
            et_mutare_loop_coloana:
                movl indexColoana,%ecx
                cmp %ecx,omiedouaspatru
                je new_line_mutare
                movl (%ebp,%ecx,4),%ebx
                movl %ebx,(%esi,%ecx,4)
                incl indexColoana
                jmp et_mutare_loop_coloana

        new_line_mutare:
            incl indexLinie
            jmp et_mutare_loop_linii

verificare:
    movl $0, indexLinie
    et_verif_linii:
        movl indexLinie,%ecx
        cmp %ecx,omiedouaspatru
        je continue
        movl %ecx,%eax
        imull omiedouaspatru,%eax
        movl %eax,%ecx
        lea (%esp,%ecx,4),%ebp
        movl $0,indexColoana
        et_verof_colo:
            movl indexColoana,%eax
            cmp %eax,omiedouaspatru
            je new_line_verif
            movl (%ebp,%eax,4),%ebx
            pushl %ebx
            pushl $formatPrintf
            call printf
            popl %ebx
            popl %ebx
            incl indexColoana
            jmp et_verof_colo
    new_line_verif:
        incl indexLinie
        pushl $newLine
        call printf
        jmp et_verif_linii

et_afisare_memorie:
    movl $0, indexLinie
    movl $0, indexColoana
    et_loop_afisare_linie:
        movl indexLinie,%eax
        cmp %eax,omiedouaspatru
        je continue
        imull omiedouaspatru,%eax
        lea (%edi,%eax,4), %esi  

        movl $0, indexColoana
        et_loop_cautare_prima_aparitie_afisare:
            movl indexColoana,%ecx
            cmp %ecx,omiedouaspatru
            je newLine_afisare

            movl (%esi,%ecx,4),%ebx

            cmp $0, %ebx
            jne gasit_primul_afisare
            incl indexColoana
            jmp et_loop_cautare_prima_aparitie_afisare
            #;daca nu e zero, am gasit prima aparitie a unui element
            jmp et_cautare_a_doua_aparitie_afisare
            et_revenire_dupa_afis:
            incl indexColoana
            jmp et_loop_cautare_prima_aparitie_afisare
        gasit_primul_afisare:
            movl indexColoana,%ecx
            movl %ecx,coloanastart
            movl (%esi,%ecx,4),%ebx
            movl %ebx,descriptorfisier

            et_cautare_a_doua_aparitie_afisare:
                movl indexColoana,%ecx
                cmp %ecx,omiedouaspatru
                je last_check_afisare_coloana
                movl (%esi,%ecx,4),%ebx
                cmp %ebx,descriptorfisier
                je continua_cautare_afisare
                #; daca nu este egal inseamna ca precedentul a fostultimul de acel fel
                decl indexColoana
                movl indexColoana,%ebx

                movl %ebx, coloanafinal
                movl coloanafinal, %eax
                pushl %eax

                movl indexLinie,%eax
                pushl %eax

                movl coloanastart, %eax
                pushl %eax

                movl indexLinie,%eax
                pushl %eax

                movl descriptorfisier,%eax
                pushl %eax

                pushl $formatAddOut
                
                call printf

                popl %ebx
                popl %ebx
                popl %ebx
                popl %ebx
                popl %ebx
                popl %ebx
              #  ;l- am afisat, deci cautam urmatorul.
                jmp et_revenire_dupa_afis


                continua_cautare_afisare:
               # ;daca este egal cu descriptorfisier, atunci cautam urm 
                incl indexColoana
                jmp et_cautare_a_doua_aparitie_afisare
            last_check_afisare_coloana:
                #; daca am ajuns iaci, inseamna ca ultimul element de pe coloana respectiva era egal cu descriptorul
                #; respectiv deoarece avem minim 2 blocuri cu alecasi descriptor.
                decl indexColoana
                movl indexColoana,%ebx
                movl %ebx, coloanafinal
                
                movl coloanafinal, %eax
                pushl %eax

                movl indexLinie,%eax
                pushl %eax

                movl coloanastart, %eax
                pushl %eax

                movl indexLinie,%eax
                pushl %eax

                movl descriptorfisier,%eax
                pushl %eax

                pushl $formatAddOut
                
                call printf

                popl %ebx
                popl %ebx
                popl %ebx
                popl %ebx
                popl %ebx
                popl %ebx

                #; dupa ce am afisat, urmeaza o linie noua
                jmp newLine_afisare

        newLine_afisare:
            movl $0,indexColoana
            incl indexLinie
            jmp et_loop_afisare_linie

et_exit:
    pushl $0
    call fflush
    popl %ebx

    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
