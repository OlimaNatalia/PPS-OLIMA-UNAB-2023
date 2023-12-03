--Consulto la tabla que contiene la informaci�n de los tickets que fueron resueltos

SELECT * FROM DWT_FT_USD_RESOLVED_REQS
WHERE CREATED_DATE >= TO_DATE('01/01/2022', 'DD/MM/YYYY')
AND REQ_TYPE_ID_SK = 3

--Busco el ID correspondiente a los incidentes y request

SELECT * FROM DWT_LK_USD_REQ_TYPE

REQ_TYPE_ID_SK = 3
REQ_TYPE_ID = I
REQ_TYPE_DESC = Incident

REQ_TYPE_ID_SK = 5
REQ_TYPE_ID = R
REQ_TYPE_DESC = Request

--Busqu� en el USD el Configuration Item Family de un incidente aleatorio y lo filtr� para encontrar los CI

SELECT * FROM DWT_LK_USD_CONFIG_ITEM_FAMILY

CONFIG_ITEM_FAMILY_NAME = Software.Application
CONFIG_ITEM_FAMILY_ID_SK = 38
CONFIG_ITEM_FAMILY_ID = 1000031

--Busco la tabla que contiene los nombres de los CI para poder encontrar sus ID


SELECT * FROM DWT_LK_USD_REQ_CONFIG_ITEMS
WHERE CONFIG_ITEM_FAMILY_ID_SK = 38
AND CI_CLASS_NAME = 'Tenaris Application' --Tambi�n lo saqu� del incidente de ejemplo desde el USD
AND REQ_CONFIG_ITEM_NAME LIKE 'BI.%' --Los CI del soporte L1 comienzan siempre con BI (Business Intelligence)

--Extraje los CI del soporte L1

--REQ_CONFIG_ITEM_ID_SK

BI.Industrial.Industrial_Performance = 136387
BI.Industrial.Engineering = 136380
BI.Industrial.Production = 136395
BI.Industrial.Production Orders = 136397
BI.Supply_Chain_Inventories = 136404
BI.Human Resources.Human Resources KPIs = 136377
BI.Industrial.Industrial_Maintenance = 136386
BI.Industrial.Internal Quality = 136391
BI.Commercial.Sales - Invoicing and Costs = 136364
BI.BI & Analytics Tools.Business Control Panel (BCP)= 136350
BI.Information Technology (IT).USD Metrics = 136400
BI.Data services.Global Planning Layer (GPL) and follow up (FUT) = 166162


--Filtro por los CI

SELECT * FROM DWT_FT_USD_RESOLVED_REQS
WHERE CREATED_DATE >= TO_DATE('01/01/2022', 'DD/MM/YYYY')
AND REQ_TYPE_ID_SK = 3
AND REQ_CONFIG_ITEM_ID_SK IN (136387, 136380, 136395, 136397, 136404, 136377, 136386, 136391, 136364, 136350, 136400, 166162)

--JOINS que podr�a hacer para que den informaci�n m�s representativa en el an�lisis exploratorio

ANALYST_CONTACT_ID_SK
REQ_CONFIG_ITEM_ID_SK	
REQ_PRIORITY_ID_SK	
REQ_IMPACT_ID_SK
REQ_URGENCY_ID_SK	
REQ_CATEGORY_ID_SK	

DAYS = REQ_OPEN_DATE_ID_SK	20230904	- REQ_RESOLVED_DATE_ID_SK	20230904

--Info extra join con REQ_ID_SK en la tabla DWT_FT_USD_REQS

REQ_USD_NUM	--N�mero de ticket
REQ_SUMMARY_DESC	--Descripci�n
END_USER_CONTACT_ID_SK	
CALLER_LOCATION_ID_SK	


--Busco las tablas look up

DWT_LK_USD_CONTACTS
DWT_LK_USD_REQ_CONFIG_ITEMS
DWT_LK_USD_REQ_IMPACT
DWT_LK_USD_REQ_URGENCY
DWT_LK_USD_REQ_PRIORITIES
SELECT * FROM DWT_LK_USD_REQ_CATEGORIES --REQ_CATEGORY_NAME
SELECT * FROM DWT_LK_USD_LOCATIONS -- LOCATION_NAME

--Tabla que tiene el estado inicial de cada incidente

SELECT * FROM DWT_FT_USD_INIT_REQS

REQ_ID  --NUMERO DE TICKET
END_USER --USUARIO AFECTADO
GROUP_INIT_CONTACT_ID_SK  --GRUPO DEL CREADOR
END_USER_CONTACT_ID_SK	 --USUARIO AFECTADO
ANALYST_INIT_CONTACT_ID_SK	--CREADO DEL TICKET
------------------------------------------------------------------------

--Armo la tabla que voy a usar y agrego los joins con las lookup

SELECT 



R.REQ_OPEN_DATE_ID_SK , I.ANALYST_INIT_CONTACT_ID_SK,

--De las lookups
T1.REQ_TYPE_DESC, --Tipo de ticket
T2.REQ_CONFIG_ITEM_NAME, --Modelo afectado	
T3.LAST_NAME AS INIT_USER_GROUP, --Grupo al que pertenece el requester
T4.REQ_PRIORITY_SYM_DESC, --Prioridad
T5.REQ_IMPACT_SYM_DESC, --Impacto en el negocio
T6.REQ_CATEGORY_NAME, --Categor�a del error o solicitud
T7.LOCATION_NAME, --Ubicaci�n del requester

--De la �ltima foto

U.END_USER_CONTACT_ID_SK, --Id del usuario afectado por el error/solicitud

--Target De la tabla de tickets resueltos

(TO_DATE(R.REQ_RESOLVED_DATE_ID_SK, 'YYYY/MM/DD') - TO_DATE(R.REQ_OPEN_DATE_ID_SK, 'YYYY/MM/DD')) AS ELAPSED_DAYS --D�as que tard� el soporte en resolver el ticket

FROM 

DWT_FT_USD_RESOLVED_REQS R

--Joins

LEFT JOIN DWT_FT_USD_REQS U ON R.REQ_ID_SK = U.REQ_ID_SK 
LEFT JOIN DWT_FT_USD_INIT_REQS I ON R.REQ_ID_SK = I.REQ_ID_SK 

LEFT JOIN DWT_LK_USD_REQ_CONFIG_ITEMS T2 ON R.REQ_CONFIG_ITEM_ID_SK	= T2.REQ_CONFIG_ITEM_ID_SK
LEFT JOIN DWT_LK_USD_CONTACTS T3 ON I.GROUP_INIT_CONTACT_ID_SK = T3.CONTACT_ID_SK
LEFT JOIN DWT_LK_USD_REQ_PRIORITIES T4 ON R.REQ_PRIORITY_ID_SK	= T4.REQ_PRIORITY_ID_SK 
LEFT JOIN DWT_LK_USD_REQ_IMPACT T5 ON R.REQ_IMPACT_ID_SK = T5.REQ_IMPACT_ID_SK 
LEFT JOIN DWT_LK_USD_REQ_CATEGORIES T6 ON T6.REQ_CATEGORY_ID_SK = U.REQ_CATEGORY_ID_SK
LEFT JOIN DWT_LK_USD_LOCATIONS T7 ON T7.LOCATION_ID_SK = U.CALLER_LOCATION_ID_SK	
LEFT JOIN DWT_LK_USD_REQ_TYPE T1 ON T1.REQ_TYPE_ID_SK = R.REQ_TYPE_ID_SK


--Filtros

WHERE 1=1 
AND R.CREATED_DATE >= TO_DATE('01/01/2020', 'DD/MM/YYYY') --Tomo desde 2020 
AND R.REQ_TYPE_ID_SK IN (3,5) --Filtro los incidentes y requests

AND R.REQ_CONFIG_ITEM_ID_SK IN (136387, 136380, 136395, 136397, 136404, 136377, 136386, 136391, 136364, 136350, 136400, 166162) --Modelos que tienen un soportista


---------------------------------------------------
