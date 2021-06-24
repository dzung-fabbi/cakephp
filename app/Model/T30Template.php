<?php

/**
 * T30Template model.
 */
class T30Template extends AppModel {
    var $name = 'T30Template';

    /**
     * Get Template By Id
     * @param: $template_id
     */
    function getInfoTemplateById($id) {
    	$options['fields'] = array(
    		'T30Template.*',
    	);

    	$options['conditions']['T30Template.id'] = $id;
    	$options['conditions']['T30Template.del_flag'] = 'N';
    	return $this->find('first', $options);
    }
    /**
     * Get Template By Template Name
     * @param: $template_name
     */
    function getTemplateByTemplateName($template_name, $company_id, $template_type) {
    	$options['fields'] = array(
    		'T30Template.*',
    	);
    	$options['conditions']['T30Template.company_id'] = $company_id;
    	$options['conditions']['T30Template.template_name'] = $template_name;
        $options['conditions']['T30Template.template_type'] = $template_type;
    	$options['conditions']['T30Template.del_flag'] = 'N';
    	return $this->find('first', $options);
    }

    function getTemplateByCompanyId($company_id, $template_type=null, $limit=null, $page=null, $sort_order=null, $filter=null) {
        $options['fields'] = array(
            'T30Template.id',
            'T30Template.template_no',
            'T30Template.template_name',
            'T30Template.description',
            'T30Template.entry_user',
            'M05User.user_name',
            'T30Template.created',
        );

        $options['joins'] = array(
            array(
                'table' => 'm05_users',
                'alias' => 'M05User',
                'type' => 'left',
                'conditions' => array(
                    'T30Template.entry_user = M05User.user_id',
                )
            )
        );

        $options['conditions']['T30Template.company_id'] = $company_id;
        $options['conditions']['T30Template.del_flag'] = 'N';
        if (isset($template_type)) {
            $options['conditions']['T30Template.template_type'] = $template_type;
        }

        if(isset($filter) && !empty($filter)){
            if(isset($filter[1])){
                $options['conditions']['T30Template.template_no LIKE'] = "%".$filter[1]."%";
            }
            if(isset($filter[2])){
                $options['conditions']['T30Template.template_name LIKE'] = "%".$filter[2]."%";
            }
            if(isset($filter[3])){
                $options['conditions']['T30Template.description LIKE'] = "%".$filter[3]."%";
            }
            if(isset($filter[4])){
                $options['conditions']['DATE_FORMAT(T30Template.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
            }
            if(isset($filter[5])){
                $options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
            }
        }

        if(isset($limit) && !empty($limit)){
            $options['limit'] = $limit;
        }
        if(isset($page) && !empty($page)){
            $options['page'] = $page;
        }

        if(isset($sort_order) && !empty($sort_order)){
            $options['order'] = $sort_order;
        }else{
            $options['order'] = Array('T30Template.template_no DESC');
        }

        return $this->find('all', $options);
    }

    function getTemplateByCompanyIdCount($company_id=null, $template_type=null, $filter) {
        $options['fields'] = array(
            'T30Template.*',
        );

        $options['joins'] = array(
            array(
                'table' => 'm05_users',
                'alias' => 'M05User',
                'type' => 'left',
                'conditions' => array(
                    'T30Template.entry_user = M05User.user_id',
                )
            )
        );

        $options['conditions']['T30Template.company_id'] = $company_id;
        $options['conditions']['T30Template.del_flag'] = 'N';
        if (isset($template_type)) {
            $options['conditions']['T30Template.template_type'] = $template_type;
        }

        if(isset($filter) && !empty($filter)){
            if(isset($filter[1])){
                $options['conditions']['T30Template.template_no LIKE'] = "%".$filter[1]."%";
            }
            if(isset($filter[2])){
                $options['conditions']['T30Template.template_name LIKE'] = "%".$filter[2]."%";
            }
            if(isset($filter[3])){
                $options['conditions']['T30Template.description LIKE'] = "%".$filter[3]."%";
            }
            if(isset($filter[4])){
                $options['conditions']['DATE_FORMAT(T30Template.created, "%Y-%m-%d %k:%i") LIKE'] = "%".$filter[4]."%";
            }
            if(isset($filter[5])){
                $options['conditions']['M05User.user_name LIKE'] = "%".$filter[5]."%";
            }
        }
        return $this->find('count', $options);
    }

    function getMaxTemplateNoByCompanyId($company_id, $template_type) {
    	$options['fields'] = array(
    		'T30Template.template_no',
    	);
    	$options['conditions']['T30Template.company_id'] = $company_id;
        $options['conditions']['T30Template.template_type'] = $template_type;
    	$options['order'] = Array('T30Template.template_no DESC');
    	return $this->find('first', $options);
    }
}