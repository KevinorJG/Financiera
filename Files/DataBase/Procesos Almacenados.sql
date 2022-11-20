	/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [id_Client]
      ,[Names]
      ,[LastNames]
      ,[Direction]
      ,[Phone]
      ,[Birthdate]
      ,[Nacionality]
      ,[Identification]
  FROM [Financiera].[dbo].[Clients]

  drop procedure sp_InsertClient
  drop procedure sp_InsertEmployee

  create procedure sp_InsertClient
	@names nvarchar(50),
	@lastnames nvarchar(50),
	@Direction nvarchar(50),
	@phone nvarchar(15),
	@Birth date,
	@Nation nvarchar(20),
	@dni nvarchar(20)
	as	
	DECLARE @value1 nvarchar(50),
			@value2 nvarchar(50),
			@value3 nvarchar(50),
			@value4 nvarchar(15),
			@value5 date,
			@value6 nvarchar(20),
			@value7 nvarchar(20)
	set @value1 = [dbo].[CleanInput](@names)
	set @value2 = [dbo].[CleanInput](@lastnames)
	set @value3 = [dbo].[CleanInput](@Direction)
	set @value4 = [dbo].[CleanInput](@phone)
	set @value5 = [dbo].[CleanInput](@Birth)
	set @value6 = [dbo].[CleanInput](@Nation)
	set @value7 = [dbo].[CleanInput](@dni)
	insert into Clients(Names,LastNames,Direction,Phone,Birthdate,Nacionality,Identification)
	values (@value1,@value2,@value3,@value4,@value5,@value6,@value7)
  
create procedure [dbo].[sp_ValidarAcceso]
@usuario varchar(50)
as
if exists (Select DNI from Employees
            where DNI = @Usuario and Status_ = 'Habilitado' )
			 select 'Acceso Exitoso' as Resultado, (E.Names +' '+E.Surnames) as NameEmployee, E.Roll
			 from Employees E			 
			 else
			 Select 'Acceso Denegado' as Resultado

create procedure sp_InsertEmployee
@Dni nvarchar(20),
@Names nvarchar(20),
@Surnames nvarchar(20),
@Roll nvarchar(15),
@Status nvarchar(10)

as
if not exists(select EM.DNI,EM.Roll from Employees AS EM
			where Em.DNI = @Dni and EM.Roll = @Roll)
			BEGIN
			insert into Employees(DNI,Names,Surnames,Roll,Status_) values(@Dni,@Names,@Surnames,@Roll,@Status)
			print 'Empleado añadido'
			END
			else
			BEGIN
			RAISERROR ('Empleado ya existe',11,1)
			END

create procedure sp_BuscarClient
@Identification nvarchar(20)
as
if exists(select C.Id_Client from Clients as C
			where C.Identification = @Identification)
			BEGIN
			select * from ClientsView where Identificación = @Identification
			END
			else
			BEGIN
			RAISERROR ('Cliente no existe',11,1)
			END

create procedure sp_ClientAccount
@Identification nvarchar(20)
as
	if exists(select C.Identification from Clients as C inner join Accounts as A on C.Id_Client = A.id_Client
				where C.Identification = @Identification)
				BEGIN
				select (C.Names+' '+C.LastNames) as Client,C.Identification, A.Type_Account,A.Type_Coin,A.Status_,A.OpenDate,ACD.Deposito from Clients as C 
				inner join Accounts as A on C.Id_Client = A.id_Client
				inner join AccountDetails ACD on A.Id_Account = ACD.id_Account
 				END
				else
				BEGIN
				RAISERROR ('No existe',11,1)
				END
go
create procedure sp_InsertCard(
@identi nvarchar(20),
@NameCard nvarchar(10),
@TypeCard nvarchar(15),
@TypeCoin nvarchar(15),
@OpenDate date,
@ExpireDate date,
@MaxAmountD money,
@MaxAmountC money,
@BaseAmountD money,
@BaseAmountC money,
@FechaPago date,
@FechaCorte date,
@NCard nvarchar(22)
)
as
DECLARE @identify int

		set @identify = (select Id_Client from Clients where Identification = @identi)
		insert into Cards(id_Client,NameCard,TypeCard,TypeCoin,OpenDate,ExpiredDate,
		MaxAmountDolar,MaxAmountCordoba,AmounBaseDolar,AmountBaseCordoba,FechaCorte,FechaPago,NumerCard)
		values(@identify,@NameCard,@TypeCard,@TypeCoin,@OpenDate,@ExpireDate,@MaxAmountD,@MaxAmountC,@BaseAmountD,@BaseAmountC,@FechaCorte,@FechaPago,@NCard)
go

create procedure sp_InsertAccount(
@identify nvarchar(20),
@id_Hideline int,
@TypeAccount nvarchar(15),
@TypeCoin nvarchar(15),
@MinAmount money,
@OpenDate date
)
as
DECLARE @id int
	SET @id = (select Id_Client from Clients where Identification = @identify)
insert into Accounts (id_Client,id_Hideline,Type_Account,Type_Coin,MinAmount,OpenDate)
values(@id,@id_Hideline,dbo.CleanInput(@TypeAccount),dbo.CleanInput(@TypeCoin),@MinAmount,@OpenDate)
go

create procedure sp_UpdateClient(
@id_Client int,
@Direction nvarchar(50),
@Phone nvarchar(10),
@Nationality nvarchar(20),
@Identification nvarchar(20)
)
as
UPDATE Clients
set Direction = @Direction, Phone = @Phone, Nacionality = @Nationality, Identification = @Identification
where Id_Client = @id_Client
go

create procedure sp_BuscarTarjeta(
@Identification nvarchar(20)
)
as
if exists(select C.id_Client from Clients as C inner join Cards as CA on C.id_Client = CA.id_Client
			where C.Identification = @Identification)
			BEGIN
			DECLARE @id int
			SET @id = (select Id_Client from Clients where Clients.Identification = @Identification)
			select * from CardsView where CardsView.Identification = @Identification
			END
			else
			BEGIN
			RAISERROR ('Tarjeta no existe',11,1)
			END

go
execute sp_BuscarTarjeta '001-050698-5689'
drop procedure sp_BuscarTarjeta

create procedure ReporteCuenta(
@Identificacion nvarchar(20)
)
as 
select AD.TransactionDate,
AC.id_Client,
(select (Clients.Names+' '+Clients.LastNames) from Clients where Identification = @Identificacion) as Titular,
AD.typeMove as 'Tipo_Moviento',
AD.TypeGestion as 'Tipo_Gestion',
AD.description_ as 'Descripcion',
AD.Deposito,
AD.Retiro
from AccountDetails as AD inner join Accounts as AC on AD.id_Account = AC.Id_Account
select Saldo from Accounts where Id_Account = @Identificacion

create procedure ReporteTarjeta(
@Identificacion nvarchar(20)
)
as
select 
from CardDetails

DBCC CHECKIDENT (AccountDetails, RESEED, 0)

insert into AccountDetails(id_Account,Deposito,Retiro,TransactionDate,TypeGestion,typeMove,description_) 
values (3,8000,0,GETDATE(),'Linea','Deposito','Deposito cuenta')

insert into AccountDetails(id_Account,Deposito,Retiro,TransactionDate,TypeGestion,typeMove,description_) 
values (3,0,5000,GETDATE(),'Mostrador','Debito','Compra mueble')



backup database Financiera
to disk = 'D:\Financiera.bak'