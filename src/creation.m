%%datamatrix creation


numbercolturemax = str2num(cell2mat(inputdlg('how many coltures you have?', 'Max Colture Number')));
numbercolture = str2num(cell2mat(inputdlg('How many coltures do you want to analyze?', 'Colture Number')));
%max_c_tot = str2num(cell2mat(inputdlg('How many days do we follow coltures?', 'days')));   % se lo tolgo � meglio
max_c_tot = 1;  %minimo ho una cellula vista per il primo giorno!
DMpp = zeros(1, 177, max_c_tot);

numberofcells = zeros(numbercolturemax, 1);


for num = 1 : numbercolture
    
    [datam, pathm] = uigetfile({'*.mat','All Files'}, 'Select datamatrixes', 'MultiSelect', 'on');

    data_select = size(datam, 2);

    if data_select ~= 14 && data_select ~= 15     %quindi ho selezionato pi� di un datamatrix
        
    b = zeros (data_select, 1);   %ci metto i valori relativi alla coltura
    c = zeros (data_select, 1);   %ci metto i valori relativi alle cellule


    for j = 1: data_select

        [a, b1, c1, d1] = strread (cell2mat(datam(j)), '%s %d %d %d', 'delimiter', '_');
        b(j) = b1;
        c(j) = c1;

    end;

    
    %max_b = max(max(b));   %massimo numero di colture

    min_c = min(min(c)); %minimo numero di cellule
    max_c = max(max(c));  %massimo numero di cellule
    
    v = cell2mat(datam(j));
    numberofcells(str2num(v(4:5)), 1) = max_c;    %memorizzo il massimo numero di cellule in questo vettore. 

    appoggio = cell(1, data_select);  %stesse dimensioni di datam
    app = 0;

    for i = min_c:max_c

       for j = 1 : data_select

           x = cell2mat(datam(j));
           x1 = str2num(x(7:8));

           if x1 == i    %non � detto che abbia tutte le c da min_c a max_c

               app = app+1;
               appoggio(1, app) = datam (j);  %appoggio contiene i nomi dei datamatrix per una particolare coltura in ordine di cellule

           end;

       end;

    end;
     %in appoggio ho i nomi dei datamatrix in ordine di cellule PER UNA SINGOLA
     %COLTURA

    DMp = zeros(max_c, 177, max_c_tot);
    %v1 = genvarname(sprintf('DMp%d', b1));
    %eval([v1 '= zeros(max_b, 177, max_c_tot)']);  %max_c_tot lo chiedi all'utente

    for i = 1 : data_select   %� la stessa dimensione di "appoggio"

        nome = cell2mat(appoggio(1, i));
        v = genvarname(nome(1 : end-4));
        cd(pathm);
        eval (['load(v)']);   %carico DM
        cd ..
        cd ..

        for j = 1 : 177

            for z = 1 : size(DM, 3)

                if max_c_tot< size(DM,3)

                    DMp = cat(3, DMp, zeros (max_c, 177, (size(DM, 3) - max_c_tot)));
                    max_c_tot = size (DM, 3);    %iterato per ogni coltura, mi rimane qui il max numero totale in assoluto!!

                end;

                cellu = cell2mat(datam(i));
                DMp(str2num(cellu(7:8)), j, z) = DM(1, j, z);

            end;

        end;

    end;       %per una coltura, riunisco i datamatrix delle singole cellule


    %v1 = genvarname(nome(1 : 5));   %
    %eval ([v1 '= DMp']);  %esempio: DM_01 per la prima coltura, che contiene tt le cellule per il max_c_tot di quella coltura.
    %save ( ['nome(1:5)', '.mat'], 'DMp');
    
    else
     
        [a, b1, c1, d1] = strread (datam, '%s %d %d %d', 'delimiter', '_');
        max_c =c1;
        DMp = zeros(c1, 177, max_c_tot);
        
        numberofcells(str2num(datam(4:5)), 1) = max_c;   
        
        v = genvarname(datam(1 : end-4));
        cd(pathm);
        eval (['load(v)']);   %carico DM
        cd .. 
        cd ..   

            for j = 1 : 177

                for z = 1 : size(DM, 3)
                    
                    if max_c_tot< size(DM,3)

                    DMp = cat(3, DMp, zeros (max_c, 177, (size(DM, 3) - max_c_tot)));
                    max_c_tot = size (DM, 3);    %iterato per ogni coltura, mi rimane qui il max numero totale in assoluto!!

                    end;

                    DMp(str2num(datam(7:8)), j, z) = DM(1, j, z);

                end;

            end;


        %v1 = genvarname(nome(1 : 5));   %
        %eval ([v1 '= DMp']);  %esempio: DM_01 per la prima coltura, che contiene tt le cellule per il max_c_tot di quella coltura.
        %save ( ['nome(1:5)', '.mat'], 'DMp');
        

        %cd ..  
        %cd ..
        
    end; 
    
    if max_c_tot > size (DMpp, 3) 
        
        DMpp = cat(3, DMpp, zeros(size(DMpp, 1), 177, (max_c_tot - size(DMpp, 3))));   %in questo modo ho lo stesso size(DMpp, 3)
        
    end; 
    
    DMg = cat(1, DMpp, DMp);
    DMpp = DMg; 
    %DMg = DMg(2:end, :,:);

end;


%da qui ho un DMp_%s per ogni coltura che si vuole analizzare. Devo fare ora
%uno stack per avere il DMg

DMg = DMpp(2:end, :, :);

save ('numberofcells.mat', 'numberofcells', '-mat')     %salvo in NE.MO. il numero di cellule, in .mat

save('datamatrix.mat', 'DMg', '-mat')

warndlg ('Datamatrix is complete!')
uiwait
