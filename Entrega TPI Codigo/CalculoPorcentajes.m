function [Datos, Test, DatosH, TestH] = CalculoPorcentajes(DatosTorneo, DatosTest, DatosHistoricos)
	[m,n]=size(DatosTorneo);
	[m1,n1]=size(DatosTest);
	

	cantPartidos = m + m1;

	mapas = [0 0 0 0 0 0 1; 0 0 0 0 0 1 0; 0 0 0 0 1 0 0; 0 0 0 1 0 0 0; 0 0 1 0 0 0 0; 0 1 0 0 0 0 0; 1 0 0 0 0 0 0];
	equipos = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0; 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];

	partidosGanados = zeros(length(equipos),1);
	partidosGanadosMapa = zeros(length(equipos),length(mapas));
	partidosJugados = zeros(length(equipos),length(mapas));
	porcentaje = zeros(length(equipos),1);
	porcentajeMapa = zeros(length(equipos),length(mapas));
	rondasGanadas = zeros(length(equipos),length(mapas));
	Monitoreo = m*0.1;

	for i=1:m-Monitoreo
		[~,local] = max(ismember(equipos, DatosTorneo(i,1:18),"rows"));
		[~,visitante] = max(ismember(equipos, DatosTorneo(i,19:36),"rows"));
		[~,mapa] = max(ismember(mapas, DatosTorneo(i,39:45),"rows"));
		rondasGanadas(local,mapa) =rondasGanadas(local,mapa)+ DatosTorneo(i,37); 
		rondasGanadas(visitante,mapa) =rondasGanadas(visitante,mapa) + DatosTorneo(i,38); 
		if(DatosTorneo(i,46) == 1)
			partidosGanados(local) = partidosGanados(local)+ 1;
			partidosGanadosMapa(local,mapa) =partidosGanadosMapa(local,mapa)+ 1;
		else
			partidosGanados(visitante) =partidosGanados(visitante)+ 1;
			partidosGanadosMapa(visitante,mapa) =partidosGanadosMapa(visitante,mapa)+ 1;
		end
		partidosJugados(local,mapa) =partidosJugados(local,mapa)+1;
		partidosJugados(visitante,mapa) =partidosJugados(visitante,mapa)+1;
	end

porcentaje = partidosGanados ./ sum(partidosJugados,2);
porcentajeMapa = partidosGanadosMapa ./ partidosJugados;
porcentajeMapa(isnan(porcentajeMapa))=0.1;
DatosHistoricos(isnan(DatosHistoricos))=0.3;
DatosHistoricos = DatosHistoricos./100;
rondasGanadas = (rondasGanadas ./ partidosJugados)./16;
rondasGanadas(isnan(rondasGanadas))=0.1;
	
	
for i=1:cantPartidos
	if(i <= m)
		[~,local] = max(ismember(equipos, DatosTorneo(i,1:18),"rows"));
		[~,visitante] = max(ismember(equipos, DatosTorneo(i,19:36),"rows"));
		[~,mapa] = max(ismember(mapas, DatosTorneo(i,39:45),"rows"));
		
		DatosH(i,:) = [ 0.6*porcentaje(local)+0.4*DatosHistoricos(local,end) 0.6*porcentaje(visitante)+0.4*DatosHistoricos(visitante,end) (0.6*porcentajeMapa(local,mapa)+0.4*DatosHistoricos(local,mapa)) (0.6*porcentajeMapa(visitante, mapa)+0.4*DatosHistoricos(visitante,mapa)) rondasGanadas(local,mapa) rondasGanadas(visitante,mapa)  DatosTorneo(i,39:45) DatosTorneo(i,end-1)];
		Datos(i,:) = [ porcentaje(local) porcentaje(visitante) porcentajeMapa(local,mapa) porcentajeMapa(visitante, mapa) rondasGanadas(local,mapa) rondasGanadas(visitante,mapa) DatosTorneo(i,39:45) DatosTorneo(i,end-1)];
	else
		[~,local] = max(ismember(equipos, DatosTest(i-m,1:18),"rows"));
		[~,visitante] = max(ismember(equipos, DatosTest(i-m,19:36),"rows"));
		[~,mapa] = max(ismember(mapas, DatosTest(i-m,39:45),"rows"));
		TestH(i-m,:) = [0.6*porcentaje(local)+0.4*DatosHistoricos(local,end) 0.6*porcentaje(visitante)+0.4*DatosHistoricos(visitante,end) (0.6*porcentajeMapa(local,mapa)+0.4*DatosHistoricos(local,mapa)) (0.6*porcentajeMapa(visitante, mapa)+0.4*DatosHistoricos(visitante,mapa)) rondasGanadas(local,mapa) rondasGanadas(visitante,mapa)  DatosTest(i-m,39:45) DatosTest(i-m,end-1)];
		Test(i-m,:) = [porcentaje(local) porcentaje(visitante) porcentajeMapa(local,mapa) porcentajeMapa(visitante, mapa) rondasGanadas(local,mapa) rondasGanadas(visitante,mapa) DatosTest(i-m,39:45) DatosTest(i-m,end-1)];
	end
	
end