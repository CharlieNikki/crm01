package org.charlienikki.crm.settings.mapper;

import org.charlienikki.crm.settings.pojo.User;

import java.util.List;
import java.util.Map;

public interface UserMapper {
    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Sat Sep 17 18:19:12 CST 2022
     */
    int deleteByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Sat Sep 17 18:19:12 CST 2022
     */
    int insert(User record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Sat Sep 17 18:19:12 CST 2022
     */
    int insertSelective(User record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Sat Sep 17 18:19:12 CST 2022
     */
    User selectByPrimaryKey(String id);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Sat Sep 17 18:19:12 CST 2022
     */
    int updateByPrimaryKeySelective(User record);

    /**
     * This method was generated by MyBatis Generator.
     * This method corresponds to the database table tbl_user
     *
     * @mbggenerated Sat Sep 17 18:19:12 CST 2022
     */
    int updateByPrimaryKey(User record);

    /**
     * 根据获取到的用户名和密码进入数据库进行查询操作
     * @return 返回用户数据
     */
    User selectUserByLoginActAndPwd(Map<String,Object> map);

    /**
     * 搜索全部用户的所有信息
     * @return 用户List集合
     */
    List<User> selectAllUsers();
}