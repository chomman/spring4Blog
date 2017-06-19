package com.walter.service;

import com.walter.dao.CategoryDao;
import com.walter.model.CategoryVO;
import com.walter.util.Message;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

/**
 * Created by yhwang131 on 2017-05-23.
 */
@Service
public class ConfigServiceImpl implements ConfigService {
	final Logger logger = LoggerFactory.getLogger(this.getClass());

	@Autowired
	private CategoryDao categoryDao;

	@Override
	public List<CategoryVO> getCategoryList() {
		return categoryDao.getCategoryList();
	}

	@Override
	public CategoryVO getCategoryItemByCd(int category_cd) {
		return categoryDao.getCategoryItemByCd(category_cd);
	}

	@Override
	public HashMap insCategoryItem(CategoryVO categoryVO) {
		HashMap resultMap = new HashMap();
		try {
			if (categoryDao.getCategoryCountByName(categoryVO.getCategory_name()) == 0) {
				int result = categoryDao.insCategoryItem(categoryVO);
				resultMap.put("success", result == 1 ? true:false);
			} else {
				resultMap.put("success", false);
				resultMap.put("message", Message.DUPLE_CATEGORY.getComment());
			}
		} catch (Exception e) {
			logger.error(e.toString());
			resultMap.put("success", false);
			resultMap.put("message", e.getMessage());
		}
		return resultMap;
	}

	@Override
	public HashMap modCategoryItem(CategoryVO categoryVO, String targetAttribute) {
		HashMap paramsMap = new HashMap(), resultMap = new HashMap();
		try {
			paramsMap.put("mod_id", categoryVO.getMod_id());
			paramsMap.put("category_cd", categoryVO.getCategory_cd());
			switch (targetAttribute) {
				case "Usage" :
					paramsMap.put("use_yn", categoryVO.isUse_yn());
					break;
				case "Order" :
					paramsMap.put("order_no", categoryVO.getOrder_no());
					break;
				case "Name" :
					paramsMap.put("category_name", categoryVO.getCategory_name());
					break;
			}
			int result = categoryDao.modCategoryItem(paramsMap);
			resultMap.put("success", result == 1 ? true:false);
		} catch (Exception e) {
			logger.error(e.toString());
			resultMap.put("success", false);
			resultMap.put("message", e.getMessage());
		}
		return resultMap;
	}

	@Override
	public HashMap delCategoryItem(int category_cd) {
		HashMap resultMap = new HashMap();
		try {
			int result = categoryDao.delCategoryItem(category_cd);
			resultMap.put("success", result == 1 ? true:false);
		} catch (Exception e) {
			logger.error(e.toString());
			resultMap.put("success", false);
			resultMap.put("message", e.getMessage());
		}
		return resultMap;
	}
}