//
//  ArchiveQueueScreenshotService.swift
//  iOS_final_project
//
//  Created by Дарья Жданок on 11.03.26.
//

import UIKit
import WebKit

final class ArchiveQueueDataService: NSObject {
    
    typealias Model = MainTableModel
    
    private enum Constants {
        static let pageURL = "https://gpk.gov.by/situation-at-the-border/arkhiv-ocheredey/"
        static let webViewWidth: CGFloat = 1280
        static let webViewHeight: CGFloat = 2200
        
        static let pageReadyTimeout: TimeInterval = 20
        static let resultReadyTimeout: TimeInterval = 20
        static let pollInterval: TimeInterval = 0.4
    }
    
    private var webView: WKWebView?
    private var completion: ((Result<Model.ArchiveQueueTableData, Error>) -> Void)?
    private var requestModel: Model.ArchiveQueueScreenshotRequest?
    private weak var hostView: UIView?
    private var isFinished = false
    
    func loadData(
        in hostView: UIView,
        request: Model.ArchiveQueueScreenshotRequest,
        completion: @escaping (Result<Model.ArchiveQueueTableData, Error>) -> Void
    ) {
        cleanup()
        
        self.hostView = hostView
        self.requestModel = request
        self.completion = completion
        self.isFinished = false
        
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        
        let webView = WKWebView(
            frame: CGRect(
                x: -5000,
                y: 0,
                width: Constants.webViewWidth,
                height: Constants.webViewHeight
            ),
            configuration: config
        )
        
        webView.navigationDelegate = self
        self.webView = webView
        hostView.addSubview(webView)
        
        guard let url = URL(string: Constants.pageURL) else {
            finishIfNeeded(.failure(Model.ArchiveQueueScreenshotError.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = 30
        webView.load(urlRequest)
    }
    
    private func pageDidLoad() {
        waitUntil(
            timeout: Constants.pageReadyTimeout,
            interval: Constants.pollInterval,
            script: pageReadyScript
        ) { [weak self] ready in
            guard let self else { return }
            
            guard ready else {
                self.finishIfNeeded(.failure(Model.ArchiveQueueScreenshotError.formFillFailed))
                return
            }
            
            self.fillFormAndSubmit()
        }
    }
    
    private func fillFormAndSubmit() {
        guard let requestModel, let webView else {
            finishIfNeeded(.failure(Model.ArchiveQueueScreenshotError.webViewMissing))
            return
        }
        
        let js = makeFillScript(
            checkpointName: requestModel.checkpointName,
            date: requestModel.date
        )
        
        webView.evaluateJavaScript(js) { [weak self] result, error in
            guard let self else { return }
            
            if let error {
                print("fill JS error =", error)
                self.finishIfNeeded(.failure(error))
                return
            }
            
            print("fill JS result =", result ?? "nil")
            
            guard let dict = result as? [String: Any] else {
                self.finishIfNeeded(.failure(Model.ArchiveQueueScreenshotError.formFillFailed))
                return
            }
            
            let checkpointOk = (dict["checkpointOk"] as? NSNumber)?.boolValue ?? false
            let dateOk = (dict["dateOk"] as? NSNumber)?.boolValue ?? false
            let buttonOk = (dict["buttonOk"] as? NSNumber)?.boolValue ?? false
            
            print("checkpointOk =", checkpointOk)
            print("dateOk =", dateOk)
            print("buttonOk =", buttonOk)
            print("checkpointText =", dict["checkpointText"] ?? "nil")
            print("checkpointValue =", dict["checkpointValue"] ?? "nil")
            print("dateValue =", dict["dateValue"] ?? "nil")
            print("buttonText =", dict["buttonText"] ?? "nil")
            
            guard checkpointOk && dateOk && buttonOk else {
                self.finishIfNeeded(.failure(Model.ArchiveQueueScreenshotError.formFillFailed))
                return
            }
            
            self.waitForResultsAndExtract()
        }
    }
    
    private func waitForResultsAndExtract() {
        waitUntil(
            timeout: Constants.resultReadyTimeout,
            interval: Constants.pollInterval,
            script: resultsReadyScript
        ) { [weak self] ready in
            guard let self else { return }
            
            guard ready else {
                self.finishIfNeeded(.failure(Model.ArchiveQueueScreenshotError.formFillFailed))
                return
            }
            
            self.extractTableData()
        }
    }
    
    private func extractTableData() {
        guard let webView else {
            finishIfNeeded(.failure(Model.ArchiveQueueScreenshotError.webViewMissing))
            return
        }
        
        let js = """
        (function() {
            function normalize(s) {
                return (s || "").replace(/\\s+/g, " ").trim();
            }

            const pageTitle = normalize(
                document.querySelector('h1, h2, h3')?.innerText || 'Архив очередей'
            );

            const bodyText = normalize(document.body.innerText || '');

            // Ищем блок после "Очереди в пункте пропуска ..."
            const startMatch = bodyText.match(/Очереди в пункте пропуска\\s+(.+?)\\s+на\\s+(\\d{2}\\.\\d{2}\\.\\d{4})/i);
            if (!startMatch) {
                return null;
            }

            const checkpointName = normalize(startMatch[1]);
            const dateText = startMatch[2];

            const startIndex = bodyText.indexOf(startMatch[0]);
            if (startIndex < 0) {
                return null;
            }

            let relevantText = bodyText.slice(startIndex);

            // Обрезаем хвост страницы после нужного блока
            const endMarkers = [
                'Информация о пунктах пропуска',
                'Интерактивная карта',
                'Графики очередей',
                'Архив очередей',
                'Расстояние до ближайшего пункта пропуска'
            ];

            let endIndex = relevantText.length;
            for (const marker of endMarkers) {
                const idx = relevantText.indexOf(marker);
                if (idx > 0 && idx < endIndex) {
                    endIndex = idx;
                }
            }

            relevantText = normalize(relevantText.slice(0, endIndex));

            // Проверяем, что внутри есть заголовки и строки времени
            const hasHeaders =
                /Выезд грузовые/i.test(relevantText) &&
                /Выезд легковые/i.test(relevantText) &&
                /Выезд автобусы/i.test(relevantText);

            const hasTimeRows = /\\d{2}:\\d{2}\\s+\\d+\\s+\\d+\\s+\\d+/i.test(relevantText);

            if (!hasHeaders || !hasTimeRows) {
                return {
                    title: pageTitle + ' — ' + checkpointName + ' — ' + dateText,
                    rows: []
                };
            }

            const rows = [];
            rows.push({
                columns: ['Время', 'Грузовые', 'Легковые', 'Автобусы']
            });

            const rowRegex = /(\\d{2}:\\d{2})\\s+(\\d+)\\s+(\\d+)\\s+(\\d+)/g;
            let match;

            while ((match = rowRegex.exec(relevantText)) !== null) {
                rows.push({
                    columns: [
                        match[1],
                        match[2],
                        match[3],
                        match[4]
                    ]
                });
            }

            return {
                title: pageTitle + ' — ' + checkpointName + ' — ' + dateText,
                rows: rows
            };
        })();
        """
        
        webView.evaluateJavaScript(js) { [weak self] result, error in
            guard let self else { return }
            
            if let error {
                print("extract JS error =", error)
                self.finishIfNeeded(.failure(error))
                return
            }
            
            print("extract parsed result =", result ?? "nil")
            
            guard
                let dict = result as? [String: Any],
                let title = dict["title"] as? String,
                let rawRows = dict["rows"] as? [[String: Any]]
            else {
                self.finishIfNeeded(.failure(Model.ArchiveQueueScreenshotError.resultNotFound))
                return
            }
            
            let rows: [Model.ArchiveQueueRow] = rawRows.compactMap { item in
                guard let columns = item["columns"] as? [String] else { return nil }
                return Model.ArchiveQueueRow(columns: columns)
            }
            
            guard rows.count > 1 else {
                self.finishIfNeeded(.failure(Model.ArchiveQueueScreenshotError.parseFailed))
                return
            }
            
            let data = Model.ArchiveQueueTableData(title: title, rows: rows)
            self.finishIfNeeded(.success(data))
        }
    }
    
    
    private func waitUntil(
        timeout: TimeInterval,
        interval: TimeInterval,
        script: String,
        completion: @escaping (Bool) -> Void
    ) {
        let deadline = Date().addingTimeInterval(timeout)
        
        func poll() {
            guard let webView else {
                completion(false)
                return
            }
            
            webView.evaluateJavaScript(script) { [weak self] result, _ in
                guard let self else { return }
                
                if self.isFinished { return }
                
                let isReady: Bool
                if let value = result as? Bool {
                    isReady = value
                } else if let value = result as? NSNumber {
                    isReady = value.boolValue
                } else {
                    isReady = false
                }
                
                if isReady {
                    completion(true)
                    return
                }
                
                if Date() >= deadline {
                    completion(false)
                    return
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                    poll()
                }
            }
        }
        
        poll()
    }
    
    private func finishIfNeeded(
        _ result: Result<Model.ArchiveQueueTableData, Error>
    ) {
        guard !isFinished else { return }
        isFinished = true
        
        let completion = self.completion
        cleanup()
        
        DispatchQueue.main.async {
            completion?(result)
        }
    }
    
    private func cleanup() {
        webView?.navigationDelegate = nil
        webView?.stopLoading()
        webView?.removeFromSuperview()
        webView = nil
        completion = nil
        requestModel = nil
        hostView = nil
    }
    
    private func makeFillScript(checkpointName: String, date: String) -> String {
        let safeCheckpoint = checkpointName
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        
        let safeDate = date
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        
        return """
        (function() {
            function normalize(s) {
                return (s || "").replace(/\\s+/g, " ").trim().toLowerCase();
            }

            function fire(el) {
                el.dispatchEvent(new Event('input', { bubbles: true }));
                el.dispatchEvent(new Event('change', { bubbles: true }));
            }

            function clickCookiesIfNeeded() {
                const buttons = Array.from(document.querySelectorAll('button, a, input[type="button"], input[type="submit"]'));
                const accept = buttons.find(el => {
                    const text = normalize(el.textContent || el.value || '');
                    return text.includes('принять') || text.includes('accept');
                });
                if (accept) {
                    accept.click();
                    return true;
                }
                return false;
            }

            function findDateInput() {
                return document.querySelector('input[type="date"]')
                    || document.querySelector('input[name*="date"]')
                    || document.querySelector('input[placeholder*="Дата"]')
                    || document.querySelector('input[placeholder*="дата"]');
            }

            function setDate(dateText) {
                const input = findDateInput();
                if (!input) { return false; }

                const parts = dateText.split('.');
                const iso = parts.length === 3 ? `${parts[2]}-${parts[1]}-${parts[0]}` : dateText;

                input.focus();

                if ((input.type || '').toLowerCase() === 'date') {
                    input.value = iso;
                } else {
                    input.value = dateText;
                }

                fire(input);
                input.blur();
                return true;
            }

            function findSelect() {
                const selects = Array.from(document.querySelectorAll('select'));
                return selects.find(s => {
                    const text = normalize(s.innerText);
                    return text.includes('пункт') ||
                           text.includes('пропуска') ||
                           text.includes('направление');
                }) || selects[0] || null;
            }

            function selectCheckpoint(nameText) {
                const select = findSelect();
                if (!select) { return { ok: false, value: null, optionText: null }; }

                const target = normalize(nameText);
                const options = Array.from(select.options || []);
                const match = options.find(option => normalize(option.textContent).includes(target));

                if (!match) {
                    return { ok: false, value: null, optionText: null };
                }

                select.value = match.value;
                select.selectedIndex = options.indexOf(match);
                fire(select);

                return {
                    ok: true,
                    value: match.value,
                    optionText: match.textContent || ''
                };
            }

            function clickShow() {
                const candidates = Array.from(document.querySelectorAll('button, input[type="submit"], a'));
                const button = candidates.find(el => {
                    const text = normalize(el.textContent || el.value || '');
                    return text.includes('показать очереди') || text === 'показать';
                });

                if (!button) { return false; }
                button.click();
                return true;
            }

            const cookiesAccepted = clickCookiesIfNeeded();
            const checkpointResult = selectCheckpoint("\(safeCheckpoint)");
            const dateOk = setDate("\(safeDate)");
            const buttonOk = clickShow();

            return {
                cookiesAccepted: cookiesAccepted,
                checkpointOk: checkpointResult.ok,
                checkpointValue: checkpointResult.value,
                checkpointText: checkpointResult.optionText,
                dateOk: dateOk,
                buttonOk: buttonOk
            };
        })();
        """
    }
    
    private var pageReadyScript: String {
        """
        (function() {
            if (document.readyState !== 'complete') { return false; }
            
            const hasSelect = !!document.querySelector('select');
            const hasInput = !!document.querySelector('input');
            const hasButton = Array.from(document.querySelectorAll('button, input[type="submit"], a'))
                .some(el => {
                    const text = (el.textContent || el.value || '').toLowerCase();
                    return text.includes('архив');
                });
            
            return hasInput && hasButton && hasSelect;
        })();
        """
    }
    
    private var resultsReadyScript: String {
        """
        (function() {
            function normalize(s) {
                return (s || "").replace(/\\s+/g, " ").trim().toLowerCase();
            }

            const tables = Array.from(document.querySelectorAll('table'));

            const hasDataTable = tables.some(table => {
                const text = normalize(table.innerText || '');
                const rows = table.querySelectorAll('tr').length;

                const looksLikeQueueTable =
                    text.includes('выезд грузовые') ||
                    text.includes('выезд легковые') ||
                    text.includes('выезд автобусы');

                const hasNumbers = /\\d+/.test(text);

                return looksLikeQueueTable && (rows > 2 || hasNumbers);
            });

            return hasDataTable;
        })();
        """
    }
}

extension ArchiveQueueDataService: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pageDidLoad()
    }
    
    func webView(
        _ webView: WKWebView,
        didFail navigation: WKNavigation!,
        withError error: Error
    ) {
        finishIfNeeded(.failure(error))
    }
    
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        finishIfNeeded(.failure(error))
    }
}
