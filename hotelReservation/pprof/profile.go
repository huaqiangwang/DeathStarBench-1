package pprof

import (
	"fmt"
	"log"
	"net/http"
	http_pprof "net/http/pprof"
	"strconv"

	"github.com/harlow/go-micro-services/tracing"
)

func StartHttp(port string) error {
    serv_port, err := strconv.Atoi(port)
    if err != nil {
	    log.Println("Unrecogized port %s", port)
	    return err
    }
    go func() {
	    log.Println(http.ListenAndServe(fmt.Sprintf(":%d", serv_port), nil))
    }()
    return nil
}


func AddHandlersToMux(mux *tracing.TracedServeMux) error {
	mux.Handle("/debug/pprof/", http.HandlerFunc(http_pprof.Index))
	mux.Handle("/debug/pprof/cmdline", http.HandlerFunc(http_pprof.Cmdline))
	mux.Handle("/debug/pprof/profile", http.HandlerFunc(http_pprof.Profile))
	mux.Handle("/debug/pprof/symbol", http.HandlerFunc(http_pprof.Symbol))
	mux.Handle("/debug/pprof/trace", http.HandlerFunc(http_pprof.Trace))
	return nil
}
