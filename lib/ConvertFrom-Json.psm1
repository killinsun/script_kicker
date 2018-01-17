#ConvertFrom-Json for powershell v2.0
function ConvertFrom-JSON{
	param(
			[Parameter(ValueFromPipeLine=$true)]
			$obj
	)

	process{
		Add-Type -AssemblyName System.Web.Extensions
		$serializer=new-object System.Web.Script.Serialization.JavaScriptSerializer
		$obj=$serializer.DeserializeObject($json)
		return $obj
	}

}