from sqlalchemy import create_engine, Column, Integer, String, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship, backref
# 引入Table类
from sqlalchemy import Table

engine = create_engine('mysql+pymysql://root:123456@localhost:3306/study?charset=utf8')
Base = declarative_base(engine)

class User(Base):
    __tablename__ = 'user'
    id = Column(Integer, primary_key=True)
    name = Column(String(64), unique=True, nullable=False)
    email = Column(String(64), unique=True)

    def __repr__(self):
        return '<User:{}>'.format(self.name)

class Course(Base):
    __tablename__ = 'course'
    id = Column(Integer, primary_key=True)
    name = Column(String(64))
    user_id = Column(Integer, ForeignKey('user.id', ondelete='CASCADE'))
    user = relationship('User',
        backref=backref('course', cascade='all, delete-orphan'))
    
    def __repr__(self):
        return '<Course: {}>'.format(self.name)

class Lab(Base):
    __tablename__ = 'lab'
    # 设置主键为外键，关联course表的id字段
    # 注意参数顺序，先定义外键，再定义主键
    id = Column(Integer, ForeignKey('course.id'), primary_key=True)
    name = Column(String(128))
    # 设置查询接口，Lab实例的course属性值为Course实例
    # Course实例的lab属性值默认为列表，列表中有一个Lab实例
    # uselist参数可以设置Course实例的lab属性值为Lab实例而非列表
    course = relationship('Course', backref=backref('lab', uselist=False))

    def __repr__(self):
        return '<Lab: {}>'.format(self.name)

# 创建Table类的实例，即中间表映射类，赋值给变量Rela
# 该类子啊实例化时，接收4个参数：
# ① 数据表名字 ②Base metadata
# ③和④两个Column（列名，数据类型，外键，主键）
Rela = Table('rela', Base.metadata,
    Column('tag_id', Integer, ForeignKey('tag.id'), primary_key=True),
    Column('course_id', Integer, ForeignKey('course.id'), primary_key=True)
)

class Tag(Base):
    __tablename__ = 'tag'
    id = Column(Integer, primary_key=True)
    name = Column(String(64), unique=True)
    # 设置查询接口，secondary指定多对多关系的中间表，注意数据类型不是字符串
    course = relationship('Course', secondary=Rela, backref='tag')

    def __repr__(self):
        return '<Tag: {}>'.format(self.name)


if __name__ == "__main__":
    # 使用声明基类的metadata对象的create_all方法创建数据表
    Base.metadata.create_all()