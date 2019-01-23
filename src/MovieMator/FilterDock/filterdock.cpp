#include "filterdock.h"
#include "ui_filterdock.h"
#include <QQuickWidget>
#include <QQuickView>
#include <QQmlContext>
#include <filterdockinterface.h>
#include <QDir>
/*
 * Copyright (c) 2016-2019 EffectMatrix Inc.
 * Author: wyl1987527 <wyl1987527@163.com>
 * Author: Author: fuyunhuaxin <2446010587@qq.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <QStandardPaths>
#include <QtQml>
#include <qmlutilities.h>
#include <qmlview.h>

FilterDock::FilterDock(MainInterface *main, QWidget *parent):
    QDockWidget(parent),
  m_qview(QmlUtilities::sharedEngine(), this)
{
    m_mainWindow = main;
    m_pFilterInfo = NULL;
    m_qview.setFocusPolicy(Qt::StrongFocus);
    setWidget(&m_qview);

    QmlUtilities::setCommonProperties(m_qview.rootContext());

    updateFilters(NULL, 0);
}

FilterDock::~FilterDock()
{
    if(m_pFilterInfo) {delete m_pFilterInfo; m_pFilterInfo = NULL;}
}

void FilterDock::resetQview()
{
    QDir viewPath = QmlUtilities::qmlDir();
    viewPath.cd("views");
    viewPath.cd("filter");
    m_qview.engine()->addImportPath(viewPath.path());

    QDir modulePath = QmlUtilities::qmlDir();
    modulePath.cd("modules");
    m_qview.engine()->addImportPath(modulePath.path());

    m_qview.setResizeMode(QQuickWidget::SizeRootObjectToView);
    m_qview.quickWindow()->setColor(palette().window().color());
    QUrl source = QUrl::fromLocalFile(viewPath.absoluteFilePath("FiltersUI.qml"));
    m_qview.setSource(source);
}

int FilterDock::updateFilters(Filter_Info * filterInfos, int nFilterCount)
{
    if(m_pFilterInfo) {delete m_pFilterInfo; m_pFilterInfo = NULL;}

    m_pFilterInfo = new FiltersInfo();
    for(int i = 0; i < nFilterCount; i++)
    {
        FilterItemInfo *filterInfo = new FilterItemInfo();

        filterInfo->setVisible(filterInfos[i].visible);
        filterInfo->setName(QString(filterInfos[i].name));
        filterInfo->setFilterType(QString(filterInfos[i].type));
        filterInfo->setImageSourcePath(QString(filterInfos[i].imageSourcePath));

        m_pFilterInfo->addFilterItemInfo(filterInfo);
    }

    qmlRegisterType<FilterItemInfo>("FilterItemInfo", 1, 0, "FilterItemInfo");

    m_qview.rootContext()->setContextProperty("filtersInfo", m_pFilterInfo);
    m_qview.rootContext()->setContextProperty("filtersResDock", this);

    resetQview();

    return 0;
}

void FilterDock::addFilterItem(int index)
{
    m_mainWindow->addFilter(index);
}


void FiltersInfo::addFilterItemInfo(FilterItemInfo *filterInfo)
{
    m_filterInfoList.append(filterInfo);
}


static FilterDock *ftDocInstance = 0;
QDockWidget *FilterDock_initModule(MainInterface *main)
{
    if (ftDocInstance == NULL)
        ftDocInstance = new FilterDock(main);

    return ftDocInstance;
}

void FilterDock_destroyModule()
{
    if(ftDocInstance) delete ftDocInstance;
}

int setFiltersInfo(Filter_Info * filterInfos, int nFilterCount)
{
    ftDocInstance->updateFilters(filterInfos, nFilterCount);

    return 0;
}

int getCurrentSelectedFilterIndex()
{
    return 0;
}
