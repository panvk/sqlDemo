create database CompanyDB
go
use CompanyDB
go
create table Department
(
 DepartmentID int identity(1,1) primary key,
 DepartmentName nvarchar(50)
)
create table Employees
(
EmployeesID int identity(1,1) primary key,
DepartmentID int references Department(DepartmentID),
Name nvarchar(50),
Sex nvarchar(10),
Salary float check(Salary>0)
)
insert into Department(DepartmentName)
select '研发部' union
select '测试部' union
select '实施部'
select * from Department
insert into Employees(DepartmentID,Name,Sex,Salary)
select 3,'刘一','男',5000 union
select 3,'陈二','女',5500 union
select 1,'张三','男',3200 union
select 1,'李四','女',3600 union
select 1,'王五','男',3000 union
select 2,'赵六','女',3200 union
select 2,'孙七','男',4000 union
select 2,'周八','女',5500 union
select 2,'吴九','男',9000 union
select 2,'郑十','女',3000
select * from Employees
select * from Department
--1. 查询男性员工工资总和比女性员工工资总和高多少
select (select sum(salary) from Employees where Sex='男')-(select sum(salary) from Employees where Sex='女')
--2. 查询员工信息 要求显示员工姓名,员工性别,部门名称,员工工资以及部门的平均工资
select Name 员工姓名,Sex 员工性别,DepartmentName 部门名称,Salary 员工工资,部门平均工资 from Employees inner join Department on Employees.DepartmentID=Department.DepartmentID inner join (select DepartmentID,avg(Salary) 部门平均工资 from Employees group by DepartmentID) T on Department.DepartmentID=T.DepartmentID
--3. 创建名为Employees1_V视图 统计部门员工信息,要求显示部门名称,员工人数,部门最高工资以及最低工资
select DepartmentName 部门名称,count(*) 员工人数,max(Salary) 部门最高工资,min(Salary) 部门最低工资 from Department inner join Employees on Department.DepartmentID=Employees.DepartmentID group by DepartmentName
go
create view Employees1_V
as
select DepartmentName 部门名称,count(*) 员工人数,max(Salary) 部门最高工资,min(Salary) 部门最低工资 from Department inner join Employees on Department.DepartmentID=Employees.DepartmentID group by DepartmentName
go
select * from Employees1_V
--4. 创建名为Employees2_V视图 统计部门员工信息,要求显示部门名称,员工人数,员工性别以及员工所在部门相同性别的平均工资
select DepartmentName 部门名称,count(*) 员工人数,Sex 员工性别,avg(Salary) 所在部门相同性别的平均工资 from Department inner join Employees on Department.DepartmentID=Employees.DepartmentID group by Sex,DepartmentName
go
create view Employees2_V
as
select DepartmentName 部门名称,count(*) 员工人数,Sex 员工性别,avg(Salary) 所在部门相同性别的平均工资 from Department inner join Employees on Department.DepartmentID=Employees.DepartmentID group by Sex,DepartmentName
go
select * from Employees2_V
--5. 添加人事部,要求做重复数据检测
insert into Department select '人事部' where not exists(select * from Department where DepartmentName='人事部')
--6. 创建名为P_SelEmployeesByDepartmentName存储过程,要求根据部门名称查询该部门所有的员工信息
if exists(select * from sys.objects where name='P_SelEmployeesByDepartmentName')
drop procedure P_SelEmployeesByDepartmentName
go
create procedure P_SelEmployeesByDepartmentName
@DepartmentName nvarchar(50)
as
begin
 select EmployeesID 员工编号,Name 员工姓名,Sex 员工性别,Salary 员工工资,Department.DepartmentID 所在部门编号,DepartmentName 部门名称 from Employees inner join Department on Employees.DepartmentID=Department.DepartmentID where DepartmentName=@DepartmentName
end
go
exec P_SelEmployeesByDepartmentName '研发部'
--7. 创建名为P_DelDepartmentByDepartmentName存储过程,要求删除指定部门名称的部门
if exists(select * from sys.objects where name='P_DelDepartmentByDepartmentName')
drop procedure P_DelDepartmentByDepartmentName
go
create procedure P_DelDepartmentByDepartmentName
@DepartmentName nvarchar(50)
as
begin
 delete from Department where DepartmentName=@DepartmentName 
 delete from Employees where DepartmentID=(select DepartmentID from Department where DepartmentName=@DepartmentName)
end
--go﻿​ 