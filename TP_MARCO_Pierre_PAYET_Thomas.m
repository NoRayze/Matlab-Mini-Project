
%Q1: Lecture du fichier signal
%Fe_min=2*F_max=200Hz %D'après le théoreme de Shanon, pour eviter le 
% repliment de spectre échantiloné sur le spectre du signal analogique.


Donnee = dlmread("Data.csv") ;
t = Donnee(:,1) ;
Amplitude=Donnee(:,2);
T = 0.005 ; %periode d'echantillonage de Data.csv

%Q2:Mise en œuvre de l’algorithme.
%1.Visualisation
subplot(3,2,1);
plot(t,Amplitude);
title('Raw Signal');

%2.Filtre Passe Bande
subplot(3,2,2);
Lowpass = filter([1 0 0 0 0 0 -2 0 0 0 0 0 1],[1 -2 1],Amplitude) ;  %Filtre passe bas
plot(t,Lowpass);
title('Low pass filtered');

delay = 6

subplot(3,2,3);
HighPass=filter([-1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 32 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1],[1 -1],Lowpass); %Filtre passe haut
plot(t,HighPass);
title('High pass filtered');

delay= delay +16;
%3 Dérivation
subplot(3,2,4);
Derivated = conv(HighPass,[-0.125 -0.250 0 0.250 0.125],'same') ;  %Permet d'effectuer les calculs plus rapidement (complexité en temps plus faible qu'avec le filter)
%Possible car signal discret
plot(t,Derivated);
title('Derivated ECG');

delay= delay+2;



subplot(3,2,5);
Carree= Derivated.*Derivated;
plot(t,Carree);
title('Squared ECG');

%4 Mise en forme des complexes QRS

Max = max(Carree) ;

Normalized = Carree/Max; %Calcul de la puissance normalisée

N=30;

Mean = conv(Normalized,[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1],'same')/N;   %On utilise une convolution avec ones(30,1)*1/30 pour effectuer la moyenne glissante plus rapidement

delay= delay +15;

Max2 = max(Mean);

Mean2 = Mean/Max2;%Renormalisation avant détection des pics

subplot(3,2,6);
plot(t,Mean2);
title('Moving windows average ECG');

%La deuxieme façon consiste à utiliser filter()

%Q5

for (i=1:delay)
	Mean2(2000-i)=[0];
end

Seuil = [1 ; Mean2>0.60] ; %Seuillage


%Calcul des fronts montants et descendants

Seuil2(1)=Seuil(1);
for (i=2:length(Seuil))
    Seuil2(i) = Seuil(i)-Seuil(i-1); %Si Seuil2 à 1 alors c'est un front montant, s'il à -1 c'est un frond descendant 
    
end

Monte =[];
Descend = [];
%Indince des fronts
for (i=1:length(Seuil2))
    if Seuil2(i)==1
        Monte = [Monte i];
    elseif Seuil2(i)==-1
        Descend = [Descend i];
    end
end
%Calcul du maximum dans chaque fenetre 
Maxi= [];
for (i=2:length(Monte))
    for j=Monte(1,i):Descend(1,i)
        Temp(1,j)=Mean2(j,1);
        Maxi(i)=max(Temp());
        
    end
end


figure('Name','Fig3');
hold on
plot(t,Donnee(:,2))
scatter(t(List),Donnee(List,2))
title('ECG Signal with R points')
hold off
