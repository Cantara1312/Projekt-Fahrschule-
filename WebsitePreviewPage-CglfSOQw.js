import { r as reactExports, e as useQuery, i as useLazyQuery, k as useMutation, j as jsxRuntimeExports, g as gql } from "./index-DPkHlaTX.js";
import { F as Frame } from "./index-CpaKoj00.js";
import { p as processBodyScripts, g as getInitialContent, r as renderToStaticMarkup } from "./scriptProcessing-JEVTOXST.js";
const GET_WEBSITE_QUERY = gql`
  query WebsitePreviewPageQuery(
    $id: String
    $publicId: String
    $versionId: String
  ) {
    websitePreview(id: $id, publicId: $publicId, versionId: $versionId) {
      id
      analyticsId
      colorPalette
      headerCodeSection {
        id
        html
      }
      footerCodeSection {
        id
        html
      }
      fonts
      scriptsInHtml
      aiWebsiteHeadHtml
      homepage {
        id
        path
        isHomepage
        aiPageHeadHtml
        codeSections {
          id
          html
        }
        javascriptFiles {
          id
          name
          isModule
        }
      }
    }
  }
`;
const GET_PAGE_BY_PATH_QUERY = gql`
  query GetPagePreviewByPathQuery(
    $websiteId: String!
    $path: String!
    $websiteVersionId: String
  ) {
    page: pagePreview(
      websiteId: $websiteId
      path: $path
      websiteVersionId: $websiteVersionId
    ) {
      id
      path
      aiPageHeadHtml
      codeSections {
        id
        html
      }
      javascriptFiles {
        id
        name
        isModule
      }
    }
  }
`;
const RESTORE_PAGE_FROM_VERSION = gql`
  mutation RestorePageFromVersion(
    $websiteId: String!
    $versionId: String!
    $pagePath: String!
  ) {
    restorePageFromVersion(
      websiteId: $websiteId
      versionId: $versionId
      pagePath: $pagePath
    ) {
      id
      path
      name
      updatedAt
    }
  }
`;
const WebsitePreviewPage = () => {
  var _a, _b, _c;
  const searchParams = new URLSearchParams(window.location.search);
  const id = searchParams.get("id");
  const publicId = searchParams.get("publicId");
  const versionId = searchParams.get("versionId");
  const initialPath = (searchParams.get("path") || "/").split("#")[0];
  const [currentPage, setCurrentPage] = reactExports.useState(initialPath);
  const [activePage, setActivePage] = reactExports.useState(null);
  const [restoreLoading, setRestoreLoading] = reactExports.useState(false);
  const [restoreSuccess, setRestoreSuccess] = reactExports.useState(false);
  const [isNavigating, setIsNavigating] = reactExports.useState(false);
  const iframeRef = reactExports.useRef(null);
  const addedJavaScriptFiles = reactExports.useRef(false);
  const {
    data: websiteData,
    loading: websiteLoading,
    error: websiteError
  } = useQuery(GET_WEBSITE_QUERY, {
    variables: {
      id,
      publicId,
      versionId
    },
    skip: !id && !publicId
  });
  const websiteId = (_a = websiteData == null ? void 0 : websiteData.websitePreview) == null ? void 0 : _a.id;
  const [fetchPageByPath, {
    data: pageData,
    loading: pageLoading,
    error: pageError
  }] = useLazyQuery(GET_PAGE_BY_PATH_QUERY);
  const [restorePageFromVersion] = useMutation(RESTORE_PAGE_FROM_VERSION);
  const loading = websiteLoading || pageLoading;
  const error = websiteError || pageError;
  const handleRestorePage = async () => {
    if (!versionId || !websiteId || !currentPage) return;
    setRestoreLoading(true);
    try {
      const apiPath = currentPage.startsWith("/") ? currentPage.substring(1) : currentPage;
      await restorePageFromVersion({
        variables: {
          websiteId,
          versionId,
          pagePath: apiPath
        }
      });
      setRestoreSuccess(true);
      setTimeout(() => setRestoreSuccess(false), 3e3);
    } catch (error2) {
      console.error("Error restoring page:", error2);
      alert("Failed to restore page: " + error2.message);
    } finally {
      setRestoreLoading(false);
    }
  };
  const RestoreBanner = () => {
    if (!versionId) return null;
    return /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "fixed left-0 right-0 top-0 z-50 bg-blue-600 px-4 py-3 text-white shadow-lg", children: /* @__PURE__ */ jsxRuntimeExports.jsxs("div", { className: "mx-auto flex max-w-7xl items-center justify-between", children: [
      /* @__PURE__ */ jsxRuntimeExports.jsxs("div", { className: "flex items-center space-x-3", children: [
        /* @__PURE__ */ jsxRuntimeExports.jsx("svg", { className: "h-5 w-5", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", children: /* @__PURE__ */ jsxRuntimeExports.jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: 2, d: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" }) }),
        /* @__PURE__ */ jsxRuntimeExports.jsx("span", { className: "font-medium", children: "You're viewing a previous version of this page" })
      ] }),
      /* @__PURE__ */ jsxRuntimeExports.jsx("button", { onClick: handleRestorePage, disabled: restoreLoading, className: `rounded-md px-4 py-2 font-medium transition-colors ${restoreSuccess ? "bg-green-500 text-white" : restoreLoading ? "cursor-not-allowed bg-blue-500 text-white opacity-75" : "bg-white text-blue-600 hover:bg-gray-100"}`, children: restoreSuccess ? /* @__PURE__ */ jsxRuntimeExports.jsxs("span", { className: "flex items-center space-x-2", children: [
        /* @__PURE__ */ jsxRuntimeExports.jsx("svg", { className: "h-4 w-4", fill: "currentColor", viewBox: "0 0 20 20", children: /* @__PURE__ */ jsxRuntimeExports.jsx("path", { fillRule: "evenodd", d: "M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z", clipRule: "evenodd" }) }),
        /* @__PURE__ */ jsxRuntimeExports.jsx("span", { children: "Restored!" })
      ] }) : restoreLoading ? /* @__PURE__ */ jsxRuntimeExports.jsxs("span", { className: "flex items-center space-x-2", children: [
        /* @__PURE__ */ jsxRuntimeExports.jsxs("svg", { className: "h-4 w-4 animate-spin", fill: "none", viewBox: "0 0 24 24", children: [
          /* @__PURE__ */ jsxRuntimeExports.jsx("circle", { className: "opacity-25", cx: "12", cy: "12", r: "10", stroke: "currentColor", strokeWidth: "4" }),
          /* @__PURE__ */ jsxRuntimeExports.jsx("path", { className: "opacity-75", fill: "currentColor", d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" })
        ] }),
        /* @__PURE__ */ jsxRuntimeExports.jsx("span", { children: "Restoring..." })
      ] }) : "Restore this page only" })
    ] }) });
  };
  const cssVariables = reactExports.useMemo(() => {
    var _a2;
    if ((_a2 = websiteData == null ? void 0 : websiteData.websitePreview) == null ? void 0 : _a2.colorPalette) {
      return Object.entries(websiteData.websitePreview.colorPalette).map(([key, value]) => `--${key}: ${value};`).join(" ");
    }
    return "";
  }, [websiteData]);
  const fonts = reactExports.useMemo(() => {
    var _a2;
    return (_a2 = websiteData == null ? void 0 : websiteData.websitePreview) == null ? void 0 : _a2.fonts;
  }, [websiteData]);
  const javascriptFiles = reactExports.useMemo(() => {
    return (activePage == null ? void 0 : activePage.javascriptFiles) || [];
  }, [activePage]);
  const contentDidMount = () => {
    if (!iframeRef.current.contentWindow || !iframeRef.current.contentWindow.document) {
      return;
    }
    const handlePopState = () => {
      const searchParams2 = new URLSearchParams(window.location.search);
      const path = (searchParams2.get("path") || "/").split("#")[0];
      setCurrentPage(path);
    };
    window.addEventListener("popstate", handlePopState);
    setupGlobalVariables(iframeRef.current.contentWindow);
    initializePageJavaScript();
  };
  const teardownJavaScriptModules = () => {
    var _a2, _b2, _c2;
    const iframeWindow = (_a2 = iframeRef.current) == null ? void 0 : _a2.contentWindow;
    const iframeDocument = (_c2 = (_b2 = iframeRef.current) == null ? void 0 : _b2.contentWindow) == null ? void 0 : _c2.document;
    if (iframeWindow == null ? void 0 : iframeWindow.landingsiteModules) {
      iframeWindow.landingsiteModules.forEach((module) => {
        if (module == null ? void 0 : module.teardown) {
          try {
            module.teardown();
          } catch (error2) {
            console.warn("Error tearing down JavaScript module:", error2);
          }
        }
      });
      iframeWindow.landingsiteModules.clear();
    }
    if (iframeDocument) {
      const existingScripts = iframeDocument.querySelectorAll("script[data-landingsite-js]");
      existingScripts.forEach((script) => script.remove());
    }
  };
  const initializePageJavaScript = reactExports.useCallback(() => {
    var _a2, _b2, _c2;
    const iframeWindow = (_a2 = iframeRef.current) == null ? void 0 : _a2.contentWindow;
    const iframeDocument = (_c2 = (_b2 = iframeRef.current) == null ? void 0 : _b2.contentWindow) == null ? void 0 : _c2.document;
    if (!iframeWindow || !iframeDocument) return;
    if (!javascriptFiles || javascriptFiles.length === 0) return;
    iframeWindow.setTimeout(() => {
      if (addedJavaScriptFiles.current) {
        teardownJavaScriptModules();
      }
      javascriptFiles.forEach((file) => {
        if (file.name === "index.js" && !file.isModule) {
          try {
            const script = iframeDocument.createElement("script");
            script.type = "module";
            script.setAttribute("data-landingsite-js", file.id);
            const moduleUrl = `${"https://api.landingsite.ai"}/serveJavaScript?id=${file.id}${versionId ? `&versionId=${versionId}` : ""}&t=${Date.now()}`;
            script.textContent = `
              import('${moduleUrl}')
                .then(module => {
                  if (!window.landingsiteModules) {
                    window.landingsiteModules = new Map();
                  }
                  window.landingsiteModules.set('${file.id}', module);
                  if (module.init) {
                    module.init();
                  }
                })
                .catch(() => {});
            `;
            iframeDocument.head.appendChild(script);
          } catch (error2) {
            console.error("Failed to prepare JavaScript file for injection:", error2);
          }
        }
      });
      addedJavaScriptFiles.current = true;
    }, 100);
  }, [javascriptFiles, versionId]);
  reactExports.useEffect(() => {
    var _a2, _b2;
    if (!((_b2 = (_a2 = iframeRef.current) == null ? void 0 : _a2.contentWindow) == null ? void 0 : _b2.document)) return;
    if (!activePage) return;
    const iframeWindow = iframeRef.current.contentWindow;
    iframeWindow.setTimeout(() => {
      initializePageJavaScript();
    }, 50);
    return () => {
      if (addedJavaScriptFiles.current) {
        teardownJavaScriptModules();
        addedJavaScriptFiles.current = false;
      }
    };
  }, [activePage, initializePageJavaScript]);
  reactExports.useEffect(() => {
    return () => {
      if (addedJavaScriptFiles.current) {
        teardownJavaScriptModules();
        addedJavaScriptFiles.current = false;
      }
    };
  }, []);
  reactExports.useEffect(() => {
    var _a2;
    setActivePage(null);
    setIsNavigating(true);
    if (currentPage === "/" || currentPage === "") {
      if ((_a2 = websiteData == null ? void 0 : websiteData.websitePreview) == null ? void 0 : _a2.homepage) {
        setActivePage(websiteData.websitePreview.homepage);
        setIsNavigating(false);
      }
    } else if (websiteId) {
      const apiPath = currentPage.startsWith("/") ? currentPage.substring(1) : currentPage;
      fetchPageByPath({
        variables: {
          websiteId,
          path: apiPath,
          websiteVersionId: versionId
        },
        fetchPolicy: "no-cache"
        // Force a network request every time
      });
    }
  }, [currentPage, websiteId, websiteData, fetchPageByPath, versionId]);
  reactExports.useEffect(() => {
    if (pageData !== void 0 && !pageLoading) {
      setIsNavigating(false);
      if (pageData == null ? void 0 : pageData.page) {
        setActivePage(pageData.page);
      }
    }
  }, [pageData, pageLoading]);
  reactExports.useEffect(() => {
    var _a2, _b2;
    if (activePage) {
      const searchParams2 = new URLSearchParams(window.location.search);
      const currentPath = searchParams2.get("path") || "/";
      const anchor = currentPath.split("#")[1];
      if (anchor && ((_b2 = (_a2 = iframeRef.current) == null ? void 0 : _a2.contentWindow) == null ? void 0 : _b2.document)) {
        let attempts = 0;
        const maxAttempts = 50;
        const interval = setInterval(() => {
          var _a3, _b3, _c2;
          attempts++;
          const lower = String(anchor).toLowerCase();
          if (lower.startsWith("http") || lower.startsWith("mailto:") || lower.startsWith("tel:")) {
            clearInterval(interval);
            return;
          }
          let anchorElement = null;
          try {
            const doc = (_b3 = (_a3 = iframeRef.current) == null ? void 0 : _a3.contentWindow) == null ? void 0 : _b3.document;
            const escaped = ((_c2 = window.CSS) == null ? void 0 : _c2.escape) ? window.CSS.escape(anchor) : anchor.replace(/[^a-zA-Z0-9\-_:.]/g, "\\$&");
            anchorElement = (doc == null ? void 0 : doc.querySelector(`#${escaped}`)) || null;
          } catch {
            anchorElement = null;
          }
          if (anchorElement) {
            anchorElement.scrollIntoView({
              behavior: "auto"
            });
            clearInterval(interval);
          } else if (attempts >= maxAttempts) {
            clearInterval(interval);
          }
        }, 100);
        return () => clearInterval(interval);
      }
    }
  }, [activePage]);
  const setupGlobalVariables = reactExports.useCallback((window2) => {
    var _a2;
    if (!window2) {
      return;
    }
    window2.LANDING_SITE_ID = (_a2 = websiteData == null ? void 0 : websiteData.websitePreview) == null ? void 0 : _a2.analyticsId;
    window2.LANDING_SITE_CONTACT_US_URL = "https://oaojaap5re2buacyhw4cycgvza0shopu.lambda-url.us-east-2.on.aws/";
    window2.LANDING_SITE_PREVIEW_REDIRECT_PATH = (path) => {
      var _a3, _b2;
      if (!path) return;
      const [rawPath, anchor] = String(path).split("#");
      let normalizedPath;
      if (!rawPath) {
        normalizedPath = currentPage;
      } else if (!rawPath.startsWith("/")) {
        normalizedPath = `/${rawPath}`;
      } else {
        normalizedPath = rawPath;
      }
      setActivePage(null);
      setCurrentPage(normalizedPath);
      const newUrl = new URL(window2.parent.location.href);
      newUrl.searchParams.set("path", normalizedPath + (anchor ? `#${anchor}` : ""));
      window2.parent.history.pushState({}, "", newUrl);
      if (!anchor) {
        (_b2 = (_a3 = iframeRef.current) == null ? void 0 : _a3.contentWindow) == null ? void 0 : _b2.scrollTo({
          top: 0,
          behavior: "auto"
        });
      }
    };
  }, [websiteData, currentPage]);
  reactExports.useEffect(() => {
    if (!iframeRef.current || !iframeRef.current.contentWindow) {
      return;
    }
    setupGlobalVariables(iframeRef.current.contentWindow);
  }, [setupGlobalVariables]);
  reactExports.useEffect(() => {
    if (!activePage) {
      return;
    }
    const timeoutId = setTimeout(() => {
      var _a2, _b2;
      const iframeDoc = (_b2 = (_a2 = iframeRef.current) == null ? void 0 : _a2.contentWindow) == null ? void 0 : _b2.document;
      if (!iframeDoc) {
        return;
      }
      const handleLinkClick = (event) => {
        var _a3, _b3, _c2;
        const target = event.target.closest("a");
        if (target && target.getAttribute("href")) {
          event.preventDefault();
          const href = target.getAttribute("href");
          if (href.startsWith("mailto:")) {
            window.parent.location.href = href;
            return;
          }
          if (href.startsWith("tel:")) {
            window.parent.location.href = href;
            return;
          }
          if (href.startsWith("http") || target.getAttribute("target") === "_blank" || ((_a3 = target.getAttribute("rel")) == null ? void 0 : _a3.includes("noopener"))) {
            window.parent.open(href, "_blank");
            return;
          }
          const [path, anchor] = href.split("#");
          if (href === "#") {
            return;
          }
          let parentSearch;
          try {
            parentSearch = window.parent.location.search;
          } catch {
            return;
          }
          let normalizedPath;
          if (!path) {
            const searchParams3 = new URLSearchParams(parentSearch);
            normalizedPath = (searchParams3.get("path") || "/").split("#")[0];
          } else if (!path.startsWith("/")) {
            normalizedPath = `/${path}`;
          } else {
            normalizedPath = path;
          }
          const searchParams2 = new URLSearchParams(parentSearch);
          const currentUrlPath = (searchParams2.get("path") || "/").split("#")[0];
          if (normalizedPath === currentUrlPath) {
            if (anchor) {
              const lower = String(anchor).toLowerCase();
              if (lower.startsWith("http") || lower.startsWith("mailto:") || lower.startsWith("tel:")) {
                window.parent.open(anchor, "_blank");
                return;
              }
              const anchorElement = iframeDoc.getElementById(anchor);
              if (anchorElement) {
                anchorElement.scrollIntoView({
                  behavior: "auto"
                });
              }
            }
            return;
          }
          const newUrl = new URL(window.parent.location.href);
          newUrl.searchParams.set("path", normalizedPath + (anchor ? `#${anchor}` : ""));
          window.parent.history.pushState({}, "", newUrl);
          setActivePage(null);
          setCurrentPage(normalizedPath);
          iframeDoc.querySelectorAll(".lg\\:group-hover\\:block").forEach((element) => {
            element.classList.add("hidden");
          });
          if (!anchor) {
            (_c2 = (_b3 = iframeRef.current) == null ? void 0 : _b3.contentWindow) == null ? void 0 : _c2.scrollTo({
              top: 0,
              behavior: "auto"
            });
          }
        }
      };
      iframeDoc.addEventListener("click", handleLinkClick, true);
      return () => {
        iframeDoc.removeEventListener("click", handleLinkClick, true);
      };
    }, 100);
    return () => {
      clearTimeout(timeoutId);
    };
  }, [activePage]);
  const LoadingWebsitePreview = () => /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "fixed inset-0 z-50 flex items-center justify-center bg-white bg-opacity-80", children: /* @__PURE__ */ jsxRuntimeExports.jsxs("div", { className: "text-center", children: [
    /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "mb-4 flex justify-center", children: /* @__PURE__ */ jsxRuntimeExports.jsxs("svg", { className: "h-12 w-12 animate-spin text-blue-500", xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", children: [
      /* @__PURE__ */ jsxRuntimeExports.jsx("circle", { className: "opacity-25", cx: "12", cy: "12", r: "10", stroke: "currentColor", strokeWidth: "4" }),
      /* @__PURE__ */ jsxRuntimeExports.jsx("path", { className: "opacity-75", fill: "currentColor", d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" })
    ] }) }),
    /* @__PURE__ */ jsxRuntimeExports.jsx("h2", { className: "text-xl font-semibold text-gray-800", children: "Loading website preview..." }),
    /* @__PURE__ */ jsxRuntimeExports.jsx("p", { className: "mt-2 text-sm text-gray-500", children: "This may take a few moments" })
  ] }) });
  const PageNotFound = () => /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "flex min-h-screen items-center justify-center bg-gradient-to-b from-gray-50 to-gray-100 px-4", children: /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "w-full max-w-2xl text-center", children: /* @__PURE__ */ jsxRuntimeExports.jsxs("div", { className: "rounded-xl border border-gray-100 bg-white p-8 shadow-lg", children: [
    /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "mb-6", children: /* @__PURE__ */ jsxRuntimeExports.jsx("svg", { className: "mx-auto h-24 w-24 text-gray-400", xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor", children: /* @__PURE__ */ jsxRuntimeExports.jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: 1.5, d: "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" }) }) }),
    /* @__PURE__ */ jsxRuntimeExports.jsx("h1", { className: "mb-4 text-4xl font-bold text-gray-900", children: "Page Not Found" }),
    /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "mb-6 break-all rounded-lg border border-gray-200 bg-gray-50 px-4 py-2 font-mono text-lg text-gray-600", children: currentPage }),
    /* @__PURE__ */ jsxRuntimeExports.jsx("p", { className: "mb-2 text-lg text-gray-600", children: "You clicked a link that leads to this page, but this page hasn't been created on your website yet." }),
    /* @__PURE__ */ jsxRuntimeExports.jsx("p", { className: "mb-8 text-gray-500", children: "You may want to either create this page or update the link to point to an existing page." }),
    /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "space-x-4", children: /* @__PURE__ */ jsxRuntimeExports.jsxs("button", { onClick: () => {
      setCurrentPage("");
      const newUrl = new URL(window.location.href);
      newUrl.searchParams.set("path", "");
      window.history.pushState({}, "", newUrl);
    }, className: "inline-flex items-center rounded-lg border border-transparent bg-blue-600 px-6 py-3 text-base font-medium text-white transition-colors duration-150 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2", children: [
      /* @__PURE__ */ jsxRuntimeExports.jsx("svg", { className: "mr-2 h-5 w-5", xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor", children: /* @__PURE__ */ jsxRuntimeExports.jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: 2, d: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" }) }),
      "Return to Homepage"
    ] }) })
  ] }) }) });
  if (!websiteLoading && websiteData && !websiteData.websitePreview) {
    console.log("[WebsitePreviewPage] Website not found or blocked", {
      id,
      publicId,
      websiteData
    });
    return /* @__PURE__ */ jsxRuntimeExports.jsx(PageNotFound, {});
  }
  if ((loading || isNavigating) && !activePage) {
    return /* @__PURE__ */ jsxRuntimeExports.jsx(LoadingWebsitePreview, {});
  }
  if (error) {
    return /* @__PURE__ */ jsxRuntimeExports.jsxs("div", { children: [
      "Error loading website: ",
      error.message
    ] });
  }
  if (!activePage) {
    return /* @__PURE__ */ jsxRuntimeExports.jsx(PageNotFound, {});
  }
  const bodyContentHtml = buildBodyContent(websiteData == null ? void 0 : websiteData.websitePreview, activePage, currentPage);
  const bodyContent = `${bodyContentHtml}${processBodyScripts((_b = websiteData == null ? void 0 : websiteData.websitePreview) == null ? void 0 : _b.scriptsInHtml)}`;
  const headContent = ((_c = websiteData == null ? void 0 : websiteData.websitePreview) == null ? void 0 : _c.aiWebsiteHeadHtml) || "";
  const pageHeadContent = activePage == null ? void 0 : activePage.aiPageHeadHtml;
  return /* @__PURE__ */ jsxRuntimeExports.jsxs(jsxRuntimeExports.Fragment, { children: [
    /* @__PURE__ */ jsxRuntimeExports.jsx(RestoreBanner, {}),
    /* @__PURE__ */ jsxRuntimeExports.jsx(Frame, { ref: iframeRef, contentDidMount, className: "absolute bg-white", style: {
      width: "100%",
      height: "100%",
      top: versionId ? "60px" : "0"
      // Add top margin when banner is shown
    }, initialContent: getInitialContent({
      cssVariables,
      fonts,
      headContent,
      pageHeadContent,
      bodyContent
    }), children: /* @__PURE__ */ jsxRuntimeExports.jsx(jsxRuntimeExports.Fragment, {}) })
  ] });
};
const buildBodyContent = (websitePreview, activePage, currentPage) => {
  var _a, _b;
  return renderToStaticMarkup(/* @__PURE__ */ jsxRuntimeExports.jsxs(jsxRuntimeExports.Fragment, { children: [
    /* @__PURE__ */ jsxRuntimeExports.jsxs("div", { className: "[font-family:var(--font-family-body)]", children: [
      ((_a = websitePreview == null ? void 0 : websitePreview.headerCodeSection) == null ? void 0 : _a.html) && /* @__PURE__ */ jsxRuntimeExports.jsx("div", { dangerouslySetInnerHTML: {
        __html: websitePreview.headerCodeSection.html
      } }),
      !activePage.codeSections && /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "my-24 flex items-center justify-center px-4", children: /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "w-full max-w-2xl text-center", children: /* @__PURE__ */ jsxRuntimeExports.jsxs("div", { className: "", children: [
        /* @__PURE__ */ jsxRuntimeExports.jsx("h1", { className: "mb-4 text-4xl font-bold text-gray-900", children: "Page Needs To Be Generated" }),
        /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "mb-6 break-all rounded-lg border border-gray-200 bg-gray-50 px-4 py-2 font-mono text-lg text-gray-600", children: currentPage }),
        /* @__PURE__ */ jsxRuntimeExports.jsx("p", { className: "mb-2 text-lg text-gray-600", children: "This page exists in your website structure but hasn't been generated yet." }),
        /* @__PURE__ */ jsxRuntimeExports.jsx("p", { className: "mb-8 text-gray-500", children: "Return to the edit page and ask the AI to generate the content for this page." }),
        /* @__PURE__ */ jsxRuntimeExports.jsx("div", { className: "space-x-4", children: /* @__PURE__ */ jsxRuntimeExports.jsxs("button", { onClick: () => {
          const newUrl = new URL(window.location.href);
          newUrl.searchParams.set("path", "");
          window.history.pushState({}, "", newUrl);
        }, className: "inline-flex items-center rounded-lg border border-transparent bg-blue-600 px-6 py-3 text-base font-medium text-white transition-colors duration-150 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2", children: [
          /* @__PURE__ */ jsxRuntimeExports.jsx("svg", { className: "mr-2 h-5 w-5", xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor", children: /* @__PURE__ */ jsxRuntimeExports.jsx("path", { strokeLinecap: "round", strokeLinejoin: "round", strokeWidth: 2, d: "M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" }) }),
          "Return to Homepage"
        ] }) })
      ] }) }) }),
      activePage.codeSections && /* @__PURE__ */ jsxRuntimeExports.jsx("div", { dangerouslySetInnerHTML: {
        __html: activePage.codeSections.map((section) => section.html).join("\n")
      } }),
      ((_b = websitePreview == null ? void 0 : websitePreview.footerCodeSection) == null ? void 0 : _b.html) && /* @__PURE__ */ jsxRuntimeExports.jsx("div", { dangerouslySetInnerHTML: {
        __html: websitePreview.footerCodeSection.html
      } })
    ] }),
    /* @__PURE__ */ jsxRuntimeExports.jsx("script", { src: "/embed/main.umd.js" }),
    (websitePreview == null ? void 0 : websitePreview.scriptsInHtml) && /* @__PURE__ */ jsxRuntimeExports.jsx("div", { dangerouslySetInnerHTML: {
      __html: websitePreview.scriptsInHtml
    } })
  ] }));
};
export {
  WebsitePreviewPage as default
};
//# sourceMappingURL=WebsitePreviewPage-CglfSOQw.js.map
