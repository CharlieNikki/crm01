package org.charlienikki.crm.commons.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * 对Date对象进行处理的工具类
 */
public class DateUtils {
    /**
     * 对指定的Date类型的数据对象进行格式化
     * @param date
     * @return
     */
    public static String formatDateTime(Date date) {
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(date);
    }
}
