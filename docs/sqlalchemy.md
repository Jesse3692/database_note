数据库是按照数据结构来组织、存储和管理数据的仓库
sql是英文structured query language的缩写，意为结构化查询语言
orm是英文object relational mapping的缩写，意为对象关系映射。在Python中我们可以把一个关系数据库的表结构映射到Python类中
python中的orm框架有，SQLobject框架、storm框架、django内置的orm、著名的SQLAlchemy

数据库操作：
连接数据库：mysql -h 127.0.0.1 -uroot -p 123456
创建指定字符集的数据库：create database study character set = UTF8;
查看MySQL数据库的默认编码格式：show variables like 'char%database';
查看数据库的创建信息：show create database study\G;

创建引擎 create_engine

```python
from sqlalchemy import create_engine
# 参数说明：数据库类型+驱动://用户名:密码@主机:端口号/数据库名?charset=编码格式
engine = create_engine('mysql://root@127.0.0.1:3306/study?charset=utf8')
```

创建映射类需要继承声明基类，使用declarative_base：

```python
from sqlalchemy.ext.declarative import declarative_base
# 创建声明基类时传入引擎
Base = declarative_base(engine)
```

创建映射类须继承声明基类。首先创建user数据表的映射类，此表存放用户数据，也就是课程作者的数据：

```python
# Column定义字段，Integer、String分别为整数和字符串数据类型
from sqlalchemy import Column, Integer, String

class User(Base):  # 继承声明基类
    __tablename__ = 'user'  # 设置数据表名字，不可省略
    id = Column(Integer, primary_key=True)  # 设置该字段为主键
    # unique设置唯一约束，nullable设置非空约束
    name = Column(String(64), unique=True, nullable=False)
    email = Column(String(64), unique=True)

    # 定义实例的打印样式
    def __repr__(self):
        return '<User: {}>'.format(self.name)
```

一对多关系

```python
from sqlalchemy import ForeignKey
from sqlalchemy.orm import relationship, backref

class Course(Base):
    __tablename__ = 'courses'
    id = Column(Integer, primary_key=True)
    name = Column(String(64))
    # Foreignkey 设置外键关联，第一个参数为字符串， user为数据表名，id为字段名
    # 第二个参数ondelete 设置删除user实例后对关联的course实例的处理规则
    # CASCADE表示级联删除，删除用户实例后，对应的课程实例也会被连带删除
    user_id = Column(Integer, ForeignKey('user.id', ondelete="CASCADE"))
    # relationship设置查询接口，以便后期进行数据库查询操作
    # 第一个参数为位置参数，参数值为外键关联的映射类名，数据类型为字符串
    # 第二个参数backef设置反向查询接口
    # backref的第一个参数 course为查询属性，User实例使用该属性可以获得相关课程实例的列表
    # backref的第二个参数cascade如此设置即可实现Python语句删除用户数据时级联删除课程数据
    user = relationship('User',
        backref=backref('course', cascade='all, delete-orphan'))

    def __repr__(self):
    return '<Course: {}>'.format(self.name)
```

定义列时常用参数表：

|   参数   |  说明    |
| :--: | :--: |
|   primary_key   |   如果设为True，这列就是表的主键   |
|   unique   |   默认是为False，如果设为True，这列不允许出现重复的值   |
|   index   |   如果设为True，为这列创建索引，提升查询效率   |
|   nullable   |   默认值为True，这列允许使用空值；如果设为False，这列不允许使用空值   |
|   default   |   为这列定义默认值   |

常用的SQLAlchemy查询关系选项（在backref中使用）：

|   选项   |   说明   |
| :--: | :--: |
|   backref   |   在关系的另一个映射类中添加反向引用   |
|   lazy   |   指定如何加载记录，select、immediate、joined、noload和dynamic   |
|   cascade   |   设置级联删除方式   |
|   uselist   |   如果设置False，查询结果不使用列表，而使用映射类实例   |
|   order_by   |    指定查询记录的排序方式  |
|   secondary   |   指定多对多关系中关系表的名字   |


创建数据表

声明基类Base在创建之后并不会主动连接数据库，因为它的默认设置为惰性模式。Base的metadata有个create_all方法，执行此方法会主动连接数据库并创建全部数据表，完成之后自动断开与数据库的连接

```python
Base.metadata.create_all()
```

完整的建表代码

添加测试数据

安装faker`pipenv install faker`

安装ipython`pipenv install ipython`

伪造数据：

```python
In [1]: from faker import Faker

In [2]: fake = Faker('zh-cn')  # 伪造中文数据

In [3]: fake.name()
Out[3]: '杜峰'

In [4]: fake.address()
Out[4]: '宁夏回族自治区柳州市双滦长沙街C座 447388'

In [5]: fake.email()
Out[5]: 'qbai@duan.cn'

In [6]: fake.url()
Out[6]: 'http://www.kongfang.cn/'

In [7]: fake.date()
Out[7]: '2018-08-28'
```

使用session处理数据

上面写了使用映射类创建数据表要用声明基类Base

处理数据的时候就要用到session了，他是sessionmaker类的实例，该实例实现了__call__方法，本身可以作为函数来执行，返回值就是能够处理数据的session

```python
from sqlalchemy.orm import sessionmaker

# 从之前的model中引入下列对象备用
from db import Base, engine, User,Course
# 将engine引擎作为参数创建session实例
session = sessionmaker(engine)()
```

当我们创建了session实例，就启动了一个操作MySQL数据库的会话

生成测试数据

在ipython中操作

```python
# 从create_data中引入相关对象
In [1]: from create_data import User, Course, session, create_courses, create_user 
# 执行创建User实例的函数
In [2]: create_user()
# session查询结果为列表，每个元素就是一个User实例
In [3]: session.query(User).all()
Out[3]:
[<User:马璐>,
 <User:赵文>,
 <User:张洋>,
 <User:王欢>,
 <User:海秀兰>,
 <User:冯宇>,
 <User:叶勇>,
 <User:雷洁>,
 <User:朱桂花>,
 <User:卢海燕>]
# 将某个User实例赋值给user变量
In [4]: user = session.query(User).all()[3]
# 查看实例的相关属性
In [5]: user.name  
Out[5]: '王欢'

In [6]: user.id
Out[6]: 4
# 执行创建Course实例的函数
In [7]: create_courses()
# 查看前四个Course实例的name属性
In [8]: for course in session.query(Course)[:4]:
   ...:     print(course.name)
   ...:
你们你们关系成功
积分服务投资内容
广告程序一种关系
部分这些而且北京
# User实例的course属性为查询接口，通过relationship设置
# 属性值为列表，里面是两个课程实例
In [9]: user.course
Out[9]: [<Course: 汽车发表因此其中>, <Course: 参加女人阅读其中>]
# 将某个课程实例赋值给course变量
In [10]: course = session.query(Course)[12]
# 课程实例的user属性为查询接口，通过relationship设置
In [11]: course.user
Out[11]: <User:叶勇>
# 将全部实例提交到对应的数据表
In [12]: session.commit()
```
接下来删除user实例，验证级联删除功能是否生效

```python
In [13]: session.delete(user)

In [14]: session.commit()
```
查看数据表的情况，如预期，user表中id为4的行被删除，course表中user_id为4的行也被删除
