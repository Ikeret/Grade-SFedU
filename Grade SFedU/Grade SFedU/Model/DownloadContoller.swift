//
//  DownloadContoller.swift
//  Grade SFedU
//
//  Created by Сергей Коршунов on 14.03.2020.
//  Copyright © 2020 Sergey Korshunov. All rights reserved.
//

import Foundation
import Alamofire
import Kanna

var testHTML = """
<!DOCTYPE html><html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><title>Численные методы (2 поток) | Сервис БРС</title><meta http-equiv="Cache-Control" content="no-cache"><link href='https://fonts.googleapis.com/css?family=PT+Sans&subset=cyrillic-ext,latin' rel='stylesheet' type='text/css'><link type="text/css" href="/static/css/common.css" rel="stylesheet" /><link type="text/css" href="/static/css/support/imgUpload.css" rel="stylesheet" /><link type="text/css" href="/static/font-awesome/css/font-awesome.min.css" rel="stylesheet" /><script type="text/javascript" src="/static/js/libs/jquery-1.11.1.min.js"></script><script type="text/javascript" src="/static/js/config.js"></script><script type="text/javascript" src="/static/js/wnd/wnd.js"></script><script type="text/javascript" src="/static/js/event_inspector/eventInspector.js"></script><script type="text/javascript" src="/static/js/supportDialog.js"></script><script type="text/javascript" src="/static/js/semesterSwitcher.js"></script><script type="text/javascript" src="/static/js/recordBookSwitcher.js"></script><script type="text/javascript" src="/static/js/profile.js"></script><script type="text/javascript" src="/static/js/settings.js"></script><script type="text/javascript" src="/static/js/libs/jquery.placeholder.js"></script><script>
    $(function() {
        $('input, textarea').placeholder();
    });

    User = {
        login: "",
        accountid: 4317,
    };
</script><style>
    .fa-bg {
        font-size: 1.5em;
        line-height: 0.75em;
        vertical-align: -15%;
    }
    .fa-md {
        font-size: 1.2em;
        line-height: 0.75em;
        vertical-align: -10%;
    }
</style><meta name="viewport" content="width=device-width, initial-scale=1.0"><link type="text/css" href="/static/css/student/discipline.css" rel="stylesheet" /><link type="text/css" href="/static/css/common/tabs.css" rel="stylesheet" /></head><body><div id="wrap" class="page"><div id="errButton"><div id="errButton_img"></div></div><div class="header_wrapper"><div class="logotype alignLeft"><a href="/" title="Перейти на главную"><i class="fa fa-home fa-bg fa-fw"></i>&nbsp;<span>Сервис БРС</span></a></div><div class="semesterLayer"><a href="#" id="changeSemester" class="semesterChanger" title="Сменить семестр"><span class="semesterChangerTitle">Семестр:</span><span class="semesterChangerSelection">Весна 2020</span><i class="fa fa-angle-down"></i></a><div class="semesterSwitcherBtn"><div class="semesterSwitcher" id="semester_12" style="display: none;"><ul><li><a href="#" id="S-12" class="switchSemester">Весна 2020</a></li><li><a href="#" id="S-11" class="switchSemester">Осень 2019</a></li><li><a href="#" id="S-10" class="switchSemester">Весна 2019</a></li><li><a href="#" id="S-9" class="switchSemester">Осень 2018</a></li><li><a href="#" id="S-8" class="switchSemester">Весна 2018</a></li><li><a href="#" id="S-7" class="switchSemester">Осень 2017</a></li><li><a href="#" id="S-6" class="switchSemester">Весна 2017</a></li><li><a href="#" id="S-5" class="switchSemester">Осень 2016</a></li><li><a href="#" id="S-4" class="switchSemester">Весна 2016</a></li><li><a href="#" id="S-3" class="switchSemester">Осень 2015</a></li><li><a href="#" id="S-2" class="switchSemester">Весна 2015</a></li><li><a href="#" id="S-1" class="switchSemester">Осень 2014</a></li></ul></div></div></div><div class="navigation"><div class="recordBookLayer"><a href="#" id="changeRecordBook" class="recordBookChanger" title="Сменить зачетку"><span class="recordBookChangerTitle">Зачетка:</span><span class="recordBookChangerSelection">ММ-17-0089</span><i class="fa fa-angle-down"></i></a><div class="recordBookSwitcherBtn"><div class="recordBookSwitcher" id="recordBook_3661" style="display: none;"><ul><li><a href="#" id="R-3661" class="switchRecordBook">ММ-17-0089</a></li></ul></div></div></div><div id="username">Сергей Коршунов</div><a href="/sign/out" title="Выход"><i class="fa fa-sign-out fa-bg fa-fw"></i></a></div></div><div class="profile_wrapper" id="profileInfo" style="display: none;"><div class="clearFix"><div class="username">Сергей Олегович Коршунов</div></div><div class="clearFix"><div class="label">Подразделение:</div><div class="content">Институт математики, механики и компьютерных наук</div></div><div class="clearFix"><div class="label">Направление:</div><div class="content">Прикладная математика и информатика</div></div><div class="clearFix profile_delimeter"><div class="label">Курс, группа:</div><div class="content">Бакалавриат, 3 курс, 2 группа</div></div><div class="clearFix"><div class="label">Тип аккаунта:</div><div class="content">Студент</div></div><div class="clearFix"><div class="label">Логин:</div><div class="content"></div></div><div class="clearFix"><div class="label">E-Mail:</div><div class="content">serkorshunov@sfedu.ru</div></div></div><div class="main_layer"><div class="main"><div class="main_top"><h3>
                    Учебная карта дисциплины                    </h3></div><div class="main_content sidePadding"><div class="pageTitle"><h2>Численные методы (2 поток)</h2></div><div class="disciplineInfo first"><div class="clearFix"><div class="label">Форма аттестации:</div><div class="content">Экзамен</div></div><div class="clearFix"><div class="label">Семестр:</div><div class="content">
        Весенний семестр
        2019/2020 учебного года
    </div></div></div><div class="disciplineInfo last"><div class="clearFix"><div class="label">Преподаватели:</div><div class="content"><div>Цывенкова Ольга Александровна</div></div></div><div class="clearFix"><div class="label">Учебная нагрузка:</div><div class="content">

        
        
                        36
            часов
            теории
        
    </div></div></div><div class="tabsWrapper noTopMargin"><div class="tabs"><div class="tab studentDisciplineTab"><a href="#">Баллы</a></div><div class="tab studentDisciplineTab"><a href="/student/discipline/31116/journal">Журнал посещений</a></div></div></div><h3 class="blockTitle">Баллы за семестр</h3><div class="blockMargin"><div class="tableTitle Module">
        Модуль 1 Методы решения задач Коши
    </div><div class="submoduleBlock"><div class="submoduleTitle">
                Тестирование
            </div><div class="submoduleRate">
                0 / 20
                                </div><div class="submodulePercent">
                0 %
                                </div><div class="submoduleDate">
                —
            </div></div><div class="submoduleBlock"><div class="submoduleTitle">
                Лабораторная работа
            </div><div class="submoduleRate">
                0 / 10
                                </div><div class="submodulePercent">
                0 %
                                </div><div class="submoduleDate">
                —
            </div></div><div class="moduleResult">
                Итого за модуль: 0 / 30
                                                    </div><div class="tableTitle Module">
        Модуль 2 Методы решения краевых задач
    </div><div class="submoduleBlock"><div class="submoduleTitle">
                Тестирование
            </div><div class="submoduleRate">
                0 / 20
                                </div><div class="submodulePercent">
                0 %
                                </div><div class="submoduleDate">
                —
            </div></div><div class="submoduleBlock"><div class="submoduleTitle">
                Лабораторная работа
            </div><div class="submoduleRate">
                0 / 10
                                </div><div class="submodulePercent">
                0 %
                                </div><div class="submoduleDate">
                —
            </div></div><div class="moduleResult">
                Итого за модуль: 0 / 30
                                                    </div></div><h3 class="blockTitle">Допуск к экзамену</h3><div class="blockMargin">
                        Для допуска к экзамену Вам необходимо получить еще 38 баллов.
                </div><div class="Middle totalRate">
    Промежуточный итог: 0 / 60
</div><h3 class="blockTitle">Экзамен</h3><div class="blockMargin"><div class="tableTitle Extra">
        Экзамен по курсу &laquo;Численные методы (2 поток)&raquo;
    </div><div class="submoduleBlock"><div class="submoduleTitle">Бонусные баллы</div><div class="submoduleRate">
            0 / 10
        </div><div class="submodulePercent">
            0 %
        </div><div class="submoduleDate">
            —
        </div></div><div class="submoduleBlock"><div class="submoduleTitle">Экзамен по курсу &laquo;Численные методы (2 поток)&raquo;</div><div class="submoduleRate">
                0 / 40
            </div><div class="submodulePercent">
                0 %
            </div><div class="submoduleDate">
                —
            </div></div></div><div class="Final totalRate">
            Итоговый рейтинг: 0 / 100
</div></div></div><div class="footer"><div class="altFooter"><span class = "attentionFooter"><a href="/instructions.pdf" title="Открыть руководство" class="attentionFooter" target="blank">Руководство пользователя Сервиса БРС (.pdf)</a> |
    </span><a href="/order248.pdf" target="blank">Положение о порядке применения БРС (.pdf)</a> |
            <a href="/faq" target="blank">ЧаВо (часто задаваемые вопросы)</a></div><div class="dev"><a href="https://vk.com/itlab_mmcs" target="_blank">IT-лаборатория мехмата ЮФУ © 2014 — 2020</a></div></div></div></div><div class="popup_overlay"><div class="popup"><div id='signin_f'><div class='auth_title'>Аутентификация</div><div class="auth_error">Неправильный логин или пароль!</div><div class='inputs'><div class="auth_form"><input type="text" id="login" name="login" placeholder="Логин или E-Mail" value=""></div><div class="auth_form"><input type="password" id="password" name="password" placeholder="Пароль" value=""></div></div><!--    --><div class="auth_form"><input type="button" id="signin_b" name="button" value="Войти"></div></div><div class='actiongrid'><a href="/sign/in">Вход через OpenID</a> | <a href="/sign/up">Активировать аккаунт</a> | <a href="/remind">Забыли пароль?</a></div></div></div></body></html>
"""

class DownloadController {
    static let basicURL = "http://grade.sfedu.ru"
    
    public static func test() {
        if let doc = try? HTML(html: testHTML, encoding: .utf8) {
            for node in doc.css("div") {
                print(node.text)
            }
        }
    }
    
    public static func loadDiscipline(discipline: String) {
        AF.request(basicURL + discipline).response { response in
//            debugPrint(response)
            let html = String(data: response.data!, encoding: .utf8)!
            if let doc = try? HTML(html: html, encoding: .utf8) {
                for node in doc.css("a") {
                    print(node.text)
                }
            }
        }
    }
}
